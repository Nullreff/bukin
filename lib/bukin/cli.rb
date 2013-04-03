require 'thor'
require 'bukin/installer'
require 'bukin/bukfile'
require 'bukin/providers/bukget'
require 'bukin/providers/bukkit_dl'

class Bukin::CLI < Thor

  desc 'install', "Download and install the resources specified in a Bukfile"
  def install
    # Parse in the Bukfile
    contents = File.read(Bukin::Bukfile::NAME)
    bukfile = Bukin::Bukfile.new
    bukfile.instance_eval(contents)
    server = bukfile.server_info
    plugins = bukfile.plugins_info

    # Grab information from the various providers
    bukkit_dl = Bukin::BukkitDl.new
    bukget = Bukin::Bukget.new

    section "Fetching information from #{bukkit_dl.api_url}" do
      server[:download_version] = bukkit_dl.resolve_version(server[:name], server[:version])
      server[:download_build] = bukkit_dl.resolve_build(server[:name], server[:version])
    end

    section "Fetching information from #{bukget.api_url}" do
      plugins.each do |plugin|
        plugin[:download_version] = bukget.resolve_version(plugin[:name], plugin[:version], server[:name])
      end
    end

    # Download and install server and plugins
    installer = Bukin::Installer.new(Dir.pwd, true)

    section "Downloading #{server[:name]} (#{server[:download_version]})" do
      installer.install(:server, bukkit_dl, server[:name], server[:download_build])
    end

    plugins.each do |plugin|
      section "Downloading #{plugin[:name]} (#{plugin[:download_version]})" do
        installer.install(:plugin, bukget, plugin[:name], plugin[:download_version], server[:name])
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
