require 'thor'
require 'open-uri'
require 'fileutils'
require 'json'
require 'bukin/lockfile'

# BukGet api
# Docs: http://bukget.org/pages/docs/API3.html
BUKGET_API = "http://api.bukget.org/3"

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
        super
    end

    desc 'server NAME', "Download and install Minecraft server software"
    option :version, :type => :string,
                     :default => 'latest-rb',
                     :aliases => '-v',
                     :desc => "The version of the server to install"
    def server(name)
        name == 'craftbukkit' || abort("Currently only craftbukkit is supported as a sever")
        version = options[:version]
        info_url = "#{BUKKIT_API}/projects/#{name}/view/#{version}/"

        begin
            shell.say "Retriving the latest information about #{name}..."
            info = JSON.parse(open(info_url).read)
            url = BUKKIT_BASE + info['file']['url']
            server_version = info['version']

            shell.say "Downloading version #{server_version} of #{name}..."
            file_name = download_to(url, SERVER_PATH)
            @lockfile.set_server(name, server_version, file_name)
            shell.say "Saved to #{file_name}"
        rescue OpenURI::HTTPError => ex
            abort("Error: #{ex}")
        end
    end

    desc 'install PLUGIN', "Download and install a plugin from bukkit dev"
    option :version, :type => :string,
                     :default => 'latest',
                     :aliases => '-v',
                     :desc => "The version of the plugin to install"
    option :server,  :type => :string,
                     :default => 'bukkit',
                     :aliases => '-s',
                     :desc => "The server type this plugin works with"
    def install(name)
        if @lockfile.plugins.has_key?(name)
            abort("The plugin #{name} is already installed")
        end

        version = options[:version]
        display_version = pretty_version(version)
        server = options[:server]
        info_url = "#{BUKGET_API}/plugins/#{server}/#{name}/#{version}"

        begin
            shell.say "Retriving the latest information about #{name}..."
            info = JSON.parse(open(info_url).read)
            url = info['versions'][0]['download']
            plugin_version = info['versions'][0]['version']

            shell.say "Downloading version #{plugin_version} of #{name}..."
            file_name = download_to(url, PLUGINS_PATH)
            @lockfile.add_plugin(name, plugin_version, file_name)
            shell.say "Saved to #{file_name}"
        rescue OpenURI::HTTPError => ex
            abort("Error: #{ex}")
        end
    end

    desc 'uninstall PLUGIN', "Uninstalls a plugin"
    def uninstall(name)
        if not @lockfile.plugins.has_key?(name)
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

private

    def download_to(url, path, content_disposition = false)
        open(url) do |download|
            file_name = if content_disposition
                            download.meta['content-disposition']
                                    .match(/filename=(\"?)(.+)\1/)[2]
                        else
                            File.basename(url)
                        end

            FileUtils.mkdir_p(path)
            open("#{path}/#{file_name}", "wb") do |file|
                file.print download.read
            end

            file_name
        end
    end

    def pretty_version(version)
        case version
        when 'latest'
            "the latest version"
        when 'latest-rb'
            "the latest recommended build"
        when 'latest-beta'
            "the latest beta build"
        when 'latest-dev'
            "the latest development build"
        when /^git-(.*)$/
            "git commit #{$1}"
        when /^build-(.*)$/
            "build \##{$1}"
        else
           "version #{version}"
        end
    end
end
