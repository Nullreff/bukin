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
        contents = File.read(Bukin::Bukfile::NAME)
        bukfile = Bukin::Bukfile.new
        bukfile.instance_eval(contents)
        server = bukfile.server_info
        plugins = bukfile.plugins_info

        section "Fetching information from #{@bukkit_dl.api_url}" do
            server[:download_version] = @bukkit_dl.resolve_version(
                server[:name],
                server[:version]
            )
            server[:download_build] = @bukkit_dl.resolve_build(
                server[:name],
                server[:version]
            )
        end

        section "Fetching information from #{@bukget.api_url}" do
            plugins.each do |plugin|
                plugin[:download_version] = @bukget.resolve_version(
                    plugin[:name],
                    plugin[:version],
                    server[:name]
                )
            end
        end

        section "Downloading #{server[:name]} (#{server[:download_version]})" do
            data, file_name = @bukkit_dl.download(server[:name], server[:download_build])
            save_download(data, file_name, SERVER_PATH)
            @lockfile.set_server(server[:name], server[:download_build], file_name)
        end

        plugins.each do |plugin|
            section "Downloading #{plugin[:name]} (#{plugin[:download_version]})" do
                data, file_name = @bukget.download(
                    plugin[:name],
                    plugin[:download_version],
                    server[:name]
                )
                save_download(data, file_name, PLUGINS_PATH)
                @lockfile.add_plugin(plugin[:name], plugin[:download_version], file_name)
            end
        end
    end

    def help(*)
        shell.say "Bukin is a plugin and server package manager for Minecraft."
        shell.say
        super
    end

private
    def section(message)
        say "#{message}... "
        yield
        say 'Done', :green
    rescue Exception => ex
        say('Error', :red)
        raise ex
    end
end
