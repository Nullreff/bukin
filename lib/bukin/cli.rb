require 'thor'
require 'fileutils'
require 'json'
require 'bukin/lockfile'
require 'bukin/installfile'
require 'bukin/providers/bukget'

# Bukkit download api
# Docs: http://dl.bukkit.org/about/
BUKKIT_API = "http://dl.bukkit.org/api/1.0/downloads"

# Base url used for bukkit downloads
BUKKIT_BASE = "http://dl.bukkit.org"

# Path to install plugins to
PLUGINS_PATH = "plugins"

# Path to install the server in
SERVER_PATH = "."

class Bukin::CLI < Thor

    def initialize(*)
        @lockfile = Bukin::Lockfile.new
        @bukget = Bukin::Bukget.new
        super
    end

    desc 'server NAME', "Download and install Minecraft server software"
    option :version, :type => :string,
                     :default => 'latest-rb',
                     :aliases => '-v',
                     :desc => "The version of the server to install"
    def server(name)
        name = 'craftbukkit' if name == 'bukkit' # Auto rename
        name == 'craftbukkit' || abort("Currently only craftbukkit is supported as a sever")

        if @lockfile.server != {} 
            if @lockfile.server['name'] == name
                abort("Server #{name} is already installed")
            else
                # Uninstall the existing server
                file = @lockfile.server['file']
                FileUtils.rm_f(file)
            end
        end

        version = options[:version]
        info_url = "#{BUKKIT_API}/projects/#{name}/view/#{version}/"

        begin
            shell.say "Retriving the latest information about #{name}..."
            info = JSON.parse(open(info_url).read)
            url = BUKKIT_BASE + info['file']['url']
            server_version = info['version']
            server_build = info['build_number']

            shell.say "Downloading version #{server_version} of #{name}..."
            file_name = download_to(url, SERVER_PATH)
            @lockfile.set_server(name, "build-#{server_build}", file_name)
            shell.say "Saved to #{file_name}"
        rescue OpenURI::HTTPError => ex
            abort("Error: #{ex}")
        end
    end

    desc 'install [PLUGIN]', "Download and install a plugin from bukkit dev"
    option :version, :type => :string,
                     :default => 'latest',
                     :aliases => '-v',
                     :desc => "The version of the plugin to install"
    option :server,  :type => :string,
                     :default => 'bukkit',
                     :aliases => '-s',
                     :desc => "The server type this plugin works with"
    def install(name = nil)
        if name
            if @lockfile.plugins.has_key?(name)
                abort("The plugin #{name} is already installed")
            end

            version = options[:version]
            server = options[:server]

            begin
                shell.say "Retriving the latest information about #{name}..."
                download_version = @bukget.resolve_version(name, version, server)

                shell.say "Downloading version #{download_version} of #{name}..."
                data, file_name = @bukget.download(name, download_version, server)
                save_download(data, file_name, PLUGINS_PATH)
                @lockfile.add_plugin(name, download_version, file_name)

                shell.say "Saved to #{file_name}"
            rescue OpenURI::HTTPError => ex
                abort("Error: #{ex}")
            end
        else
            contents = File.read(INSTALL_FILE)
            installfile = Bukin::Installfile.new
            installfile.instance_eval(contents)
            shell.say installfile.to_yaml
        end
    end

    desc 'uninstall PLUGIN', "Uninstalls a plugin"
    def uninstall(name)
        unless @lockfile.plugins.has_key?(name)
            abort("The plugin #{name} is not currently installed")
        end

        version = @lockfile.plugins[name]['version']
        files = @lockfile.plugins[name]['files']
        files.each {|file| FileUtils.rm_f("#{PLUGINS_PATH}/#{file}")}
        @lockfile.remove_plugin(name)
        shell.say "Uninstalled version #{version} of #{name}"
    end

    def help(*)
        shell.say "Bukin is a plugin and server package manager for Minecraft."
        shell.say
        super
    end
end
