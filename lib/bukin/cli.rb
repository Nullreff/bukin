require 'thor'
require 'open-uri'
require 'bukin'
require 'bukin/installer'
require 'bukin/bukfile'
require 'bukin/bukget'
require 'bukin/bukkit_dl'
require 'bukin/jenkins'
require 'bukin/download'

module Bukin
  class CLI < Thor
    desc 'install [NAMES]', "Download and install the resources specified in a "\
                            "Bukfile.\nOptionally specify the names of specific "\
                            "plugins to install."
    def install(*names) # Parse in the Bukfile
      raw_resources = parse_resources(names)

      # Get all the informatin needed to install
      resources = prepare_resources(raw_resources)

      # Download and install all resources
      install_resources(resources)
    end

    def help(*)
      shell.say "Bukin is a plugin and server package manager for Minecraft.\n"
      super
    end

  private
    def parse_resources(names)
      resources = section('Parsing Bukfile') {Bukin::Bukfile.new.resources}

      # If name are specified, only install resources with those names
      resources.select! {|resource| names.include?(resource[:name])} if names.any?
      raise Bukin::BukinError, "Nothing to install" if resources.empty?

      resources
    end

    def prepare_resources(raw_resources)
      downloads = {}
      final_resources = []

      raw_resources.each do |data|
        name, provider = prepare(data)

        unless provider.is_a?(Download)
          # If the provider is set, we add it to the list of datas that
          # require information to be downloaded from a server before they can
          # be downloaded themselves
          url = data[name]
          downloads[url] ||= []
          downloads[url] << data
        else
          # Otherwise we push it to the final list
          final_datas << data
        end
      end

      downloads.each do |provider, datas|
        section "Fetching information from #{url}" do
          datas.each do |data|
            begin
              final_resources << provider.find_resource(data)
            rescue OpenURI::HTTPError => ex
              raise Bukin::BukinError,
                "There was an error fetching information about "\
                "'#{data[:name]} (#{data[:version]})'.\n"\
                "#{ex.message}"
            end
          end
        end
      end

      final_resources
    end

    def install_resources(resources)
      installer = Bukin::Installer.new(Dir.pwd, true)

      resources.each do |resource|
        downloading resource[:name], resource[:version] do
          begin
            installer.install(resource)
          rescue OpenURI::HTTPError => ex
            raise(
              Bukin::BukinError,
              "There was an error installing "\
              "'#{resource[:name]} (#{resource[:version]})'.\n"\
              "#{ex.message}"
            )
          end
        end
      end
    end

    PROVIDERS = {
      download: Download,
      jenkins: Jenkins,
      bukget: Bukget,
      bukkit_dl: BukkitDl
    }

    DEFAULTS = {
      server: :bukkit_dl,
      plugin: :bukget
    }

    def prepare(data)
      name, provider = PROVIDERS.find {|n, p| data[n]}

      # If this resource doesn't have a provider, we assign a default
      unless name
        name = DEFAULTS[data[:type]]
        raise MissingProviderError.new(data) unless name
        provider = PROVIDERS[name]
        data[name] = provider::URL
      end

      return name, provider
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
  end
end
