require 'thor'
require 'bukin/installer'
require 'bukin/bukfile'
require 'bukin/providers/bukget'
require 'bukin/providers/bukkit_dl'
require 'bukin/providers/direct_dl'
require 'bukin/providers/jenkins'

class Bukin::CLI < Thor

  desc 'install [NAMES]', "Download and install the resources specified in a Bukfile"
  def install(*names)
    # Parse in the Bukfile
    resources = parse_resources(names)

    # Get all the informatin needed to install
    prepare_resources(resources)

    # Download and install all resources
    install_resources(resources)
  end

  def help(*)
    shell.say "Bukin is a plugin and server package manager for Minecraft.\n"
    super
  end

private
  def parse_resources(names)
    resources = section 'Parsing Bukfile' do
      Bukin::Bukfile.new.resources
    end

    # If name are specified, only install resources with those names
    if names.any?
      resources.select! {|resource| names.include? resource[:name]}
      raise Bukin::BukinError, "Nothing to install" if resources.empty?
    end

    resources
  end

  def prepare_resources(resources)
    # Grab information from the various providers
    direct_dl = Bukin::DirectDl.new
    jenkins = Bukin::Jenkins.new
    bukkit_dl = Bukin::BukkitDl.new
    bukget = Bukin::Bukget.new

    # Provider specific resources
    direct_dl_resources = []
    jenkins_resources = []
    bukget_resources = []

    resources.each do |resource|
      if direct_dl.usable(resource)
        direct_dl_resources << resource
      elsif jenkins.usable(resource)
        jenkins_resources << resource
      else
        bukget_resources << resource
      end
    end

    direct_dl_resources.each do |resource|
      direct_dl.resolve_info(resource)
    end

    jenkins_resources.each do |resource|
      fetching jenkins.url(resource) do
        jenkins.resolve_info(resource)
      end
    end

    if bukget_resources.any?
      fetching bukget.url do
        bukget_resources.each do |resource|
          resources.each do |resource|
            resource[:server] ||= 'craftbukkit'
            begin
              bukget.resolve_info(resource)
            rescue OpenURI::HTTPError => ex
              raise Bukin::BukinError, "There was an error downloading #{resource[:name]} (#{resource[:version]}).\n#{ex.message}"
            end
          end
        end
      end
    end
  end

  def install_resources(resources)
    installer = Bukin::Installer.new(Dir.pwd, true)

    resources.each do |resource|
      downloading resource[:name], resource[:version] do
        installer.install(resource)
      end
    end
  end

  def section(message)
    say "#{message}... "
    value = yield
    say 'Done', :green
    value
  rescue => ex
    say 'Error', :red
    raise ex
  end

  def downloading(name, version, &block)
    msg = "Downloading #{name}"
    msg << " (#{version})" if version
    section(msg, &block)
  end

  def fetching(url, &block)
    section("Fetching information from #{url}", &block)
  end
end
