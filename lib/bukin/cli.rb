require 'thor'
require 'open-uri'
require 'fileutils'

BASE = "http://api.bukget.org/3"
PLUGINS_PATH = "plugins"

class Bukin::CLI < Thor

    def initialize(*)
        super
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
    def install(plugin)
        url = "#{BASE}/plugins/#{options[:server]}/#{plugin}/#{options[:version]}/download"

        open(url) do |download|
            file_name = download.meta['content-disposition']
                                .match(/filename=(\"?)(.+)\1/)[2]

            FileUtils.mkdir_p(PLUGINS_PATH)
            open("#{PLUGINS_PATH}/#{file_name}", "wb") do |file|
                file.print download.read
            end
        end
    end

    def help(*)
        shell.say "Bukin is a plugin and server package manager for Minecraft."
        shell.say
        super
    end
end
