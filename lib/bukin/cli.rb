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

  def prepare_resources(raw_resources)
    resources = {}

    # Needs to:
    # * Display Url
    # * Resolve information

    raw_resources.each do |resource|
      next if resource[:download]
      if resource[:jenkins]
        url = resource[:jenkins]
        resources[url] ||= []
        resources[url] << Bukin::Jenkins.new(resource)
      elsif resource[:bukkit_dl]
        url = resource[:bukkit_dl]
        resources[url] ||= []
        resources[url] << Bukin::BukkitDl.new(resource)
      elsif resource[:bukget]
        url = resource[:bukget]
        resources[url] ||= []
        resources[url] << Bukin::Bukget.new(resource)
      else
        raise Bukin::BukinError, "Unable to determine the provider for the resource'#{resource[:name]}'"
      end
    end

    resources.each do |url, resources|
      fetching url do
        resources.each do |resource|
          begin
            resource.resolve_info
          rescue OpenURI::HTTPError => ex
            raise Bukin::BukinError, "There was an error downloading #{resource[:name]} (#{resource[:version]}).\n#{ex.message}"
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
    section("Fetching information from #{url}", &block) if url
  end
end
