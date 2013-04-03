require 'thor'
require 'bukin/lockfile'
require 'bukin/bukfile'
require 'bukin/providers/bukget'
require 'bukin/providers/bukkit_dl'

# Path to install plugins to
PLUGINS_PATH = "plugins"

# Path to install the server in
SERVER_PATH = "."

class Bukin::CLI < Thor

    def initialize(*)
        @lockfile = Bukin::Lockfile.new
        @bukget = Bukin::Bukget.new
        @bukkit_dl = Bukin::BukkitDl.new
        super
    end

    desc 'install', "Download and install the resources specified in a Bukfile"
    def install
        say 'Parsing Bukfile... '
        contents = File.read(Bukin::Bukfile::NAME)
        bukfile = Bukin::Bukfile.new
        bukfile.instance_eval(contents)
        say 'Done', :green

        server = bukfile.server_info
        plugins = bukfile.plugins_info

        say "Fetching information from #{@bukkit_dl.api_url}... "
        server[:download_version] = @bukkit_dl.resolve_version(
            server[:name], 
            server[:version]
        )
        server[:download_build] = @bukkit_dl.resolve_build(
            server[:name],
            server[:version]
        )
        say 'Done', :green

        say "Fetching information from #{@bukget.api_url}... "
        plugins.each do |plugin|
            plugin[:download_version] = @bukget.resolve_version(
                plugin[:name], 
                plugin[:version], 
                server[:name]
            )
        end
        say 'Done', :green

        say "Downloading #{server[:name]} (#{server[:download_version]})... "
        data, file_name = @bukkit_dl.download(server[:name], server[:download_build])
        save_download(data, file_name, SERVER_PATH)
        @lockfile.set_server(server[:name], server[:download_build], file_name)
        say 'Done', :green

        plugins.each do |plugin|
            say "Downloading #{plugin[:name]} (#{plugin[:download_version]})... "
            data, file_name = @bukget.download(plugin[:name], plugin[:download_version], server[:name])
            save_download(data, file_name, PLUGINS_PATH)
            @lockfile.add_plugin(plugin[:name], plugin[:download_version], file_name)
            say 'Done', :green
        end
    rescue Exception => ex
        say('Error', :red)
        raise ex
    end

    def help(*)
        shell.say "Bukin is a plugin and server package manager for Minecraft."
        shell.say
        super
    end
end
