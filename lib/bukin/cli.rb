require 'thor'
require 'open-uri'
require 'bukin'
require 'bukin/installer'
require 'bukin/bukfile'
require 'bukin/bukget'
require 'bukin/bukkit_dl'
require 'bukin/jenkins'

module Bukin
  class CLI < Thor
    desc 'install [NAMES]', "Download and install the resources specified in a "\
                            "Bukfile.\nOptionally specify the names of specific "\
                            "plugins to install."
    def install(*names)
      # Parse in the Bukfile
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

      raw_resources.each do |resource|

        if provider
          # If the provider is set, we add it to the list of resources that
          # require information to be downloaded from a server before they can
          # be downloaded themselves
          url = resource[name]
          downloads[url] ||= []
          downloads[url] << provider.new(resource)
        else
          # Otherwise we push it to the final list
          final_resources << resource
        end
      end

      downloads.each do |url, resources|
        section "Fetching information from #{url}" do
          resources.each do |resource|
            begin
              final_resources << resource.resolve_info
            rescue OpenURI::HTTPError => ex
              raise Bukin::BukinError,
                "There was an error fetching information about "\
                "'#{resource.data[:name]} (#{resource.data[:version]})'.\n"\
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
