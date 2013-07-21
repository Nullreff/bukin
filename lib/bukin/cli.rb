require 'thor'
require 'bukin/installer'
require 'bukin/bukfile'
require 'bukin/providers/bukget'
require 'bukin/providers/bukkit_dl'
require 'bukin/providers/direct_dl'
require 'bukin/providers/jenkins'

class Bukin::CLI < Thor
  PROVIDERS = {
    :bukkit_dl => Bukin::BukkitDl,
    :bukget => Bukin::Bukget,
    :jenkins => Bukin::Jenkins
  }

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

    raw_resources.each do |resource|
      name, provider = PROVIDERS.find {|name, p| resource[name]}
      next unless name

      url = resource[name]
      resources[url] ||= []
      resources[url] << provider.new(resource)
    end

    resources.each do |url, resources|
      fetching url do
        resources.each do |resource|
          begin
            resource.resolve_info
          rescue OpenURI::HTTPError => ex
            raise Bukin::BukinError, "There was an error fetching information about '#{resource[:name]} (#{resource[:version]})'.\n#{ex.message}"
          end
        end
      end
    end
  end

  def install_resources(resources)
    installer = Bukin::Installer.new(Dir.pwd, true)

    resources.each do |resource|
      downloading resource[:name], resource[:version] do
        begin
          installer.install(resource)
        rescue OpenURI::HTTPError => ex
          raise Bukin::BukinError, "There was an error installing '#{resource[:name]} (#{resource[:version]})'.\n#{ex.message}"
        end
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
