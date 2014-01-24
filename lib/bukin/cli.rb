require 'thor'
require 'open-uri'
require 'bukin'
require 'bukin/installer'
require 'bukin/bukfile'
require 'bukin/bukget'
require 'bukin/bukkit_dl'
require 'bukin/jenkins'
require 'bukin/download'
require 'bukin/state'

module Bukin
  class CLI < Thor
    desc 'install [NAMES]', "Download and install the resources specified in a "\
                            "Bukfile.\nOptionally specify the names of specific "\
                            "plugins to install."
    option :without, type: :array, default: [], desc: 'Groups to exclude when installing'
    def install(*names) # Parse in the Bukfile
      without = options[:without].map(&:to_sym)
      raw_resources = parse_resources(names, without)

      # Get all the informatin needed to install
      resources = prepare_resources(raw_resources)

      # Download and install all resources
      install_resources(resources)
    end

    desc 'init', "Creates a new Bukfile with craftbukkit as a server and adds"\
                 "the .bukin directory to any existing .gitignore file."
    def init
      path = File.join(Dir.pwd, Bukfile::FILE_NAME)
      if File.exist?(path)
        say 'Bukfile already exists'
      else
        say 'Creating Bukfile'
        File.open(path, 'w') {|file| file.write("server 'craftbukkit'")}
      end

      if File.exist?('.gitignore') && File.readlines('.gitignore').grep(/\.bukin/).empty?
        say 'Writing .bukin to gitignore'
        File.open('.gitignore', 'a') {|file| file.write('.bukin')}
      end
    end

    def help(*)
      shell.say "Bukin is a plugin and server package manager for Minecraft.\n"
      super
    end

  private
    def parse_resources(names, without)
      resources = section('Parsing Bukfile') {Bukin::Bukfile.new.resources}

      # If name are specified, only install resources with those names
      resources.select! {|resource| names.include?(resource[:name])} if names.any?

      # Skip any resources that only exist in excluded groups
      if without.any?
        resources.select! do |resource|
          resource[:group].empty? || (resource[:group] - without).any?
        end
      end
      raise Bukin::BukinError, "Nothing to install" if resources.empty?

      resources
    end

    def prepare_resources(raw_resources)
      downloads = {}
      final_resources = []

      raw_resources.group_by {|data| get_provider(data)}.each do |name, datas|
        datas.group_by {|data| data[name]}.each do |url, data|
          downloads[PROVIDERS[name].new(url)] = data
        end
      end

      downloads.each do |provider, datas|
        fetching_section provider do
          datas.each do |data|
            begin
              version, download = provider.find(data)
              final_resources << Resource.new(data, version, download)
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
      installer = Installer.new(Dir.pwd, true)
      state = State.new(Dir.pwd)

      resources.each do |resource|
        if state.files.installed?(resource.name, resource.version)
          using_section(resource.name, resource.version)
          next
        else
          state.files.delete(resource.name)
        end

        installing_section resource.name, resource.version do
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

    def get_provider(data)
      name = PROVIDERS.keys.find {|n| data[n]}

      # If this resource doesn't have a provider, we assign a default
      unless name
        name = DEFAULTS[data[:type]]
        raise MissingProviderError.new(data) unless name
        data[name] = PROVIDERS[name]::URL
      end

      name
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

    def installing_section(name, version, &block)
      msg = "Installing #{name}"
      msg << " (#{version})" if version
      section(msg, &block)
    end

    def using_section(name, version)
      msg = "Using #{name}"
      msg << " (#{version})" if version
      section(msg) {}
    end

    def fetching_section(provider, &block)
      if provider.is_a?(Download)
        yield
      else
        section("Fetching information from #{provider.url}", &block)
      end
    end
  end
end
