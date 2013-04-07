require 'thor'
require 'socket'
require 'bukin/installer'
require 'bukin/bukfile'
require 'bukin/providers/bukget'
require 'bukin/providers/bukkit_dl'

class Bukin::CLI < Thor

  desc 'install', "Download and install the resources specified in a Bukfile"
  def install
    # Parse in the Bukfile
    bukfile = Bukin::Bukfile.new
    section 'Parsing Bukfile' do
      contents = File.read(Bukin::Bukfile::NAME)
      bukfile.instance_eval(contents)
    end
    server = bukfile.server_info
    plugins = bukfile.plugins_info

    # Grab information from the various providers
    bukkit_dl = Bukin::BukkitDl.new
    bukget = Bukin::Bukget.new

    section "Fetching information from #{bukkit_dl.api_url}" do
      info = bukkit_dl.info(server[:name], server[:version])
      server[:download_version] = info['version']
      server[:download_build] = "build-#{info['build_number']}"
    end

    section "Fetching information from #{bukget.api_url}" do
      plugins.each do |plugin|
        info = bukget.info(plugin[:name], plugin[:version], server[:name])
        plugin[:download_version] = info['versions'][0]['version']
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
  rescue => ex
    say 'Error', :red
    if ex.class == SocketError
      say ex.message
      abort 'Check that you have a stable connection and the service is online'
    elsif ex.class == Errno::ENOENT
      abort ex.message
    else
      raise ex
    end
  end
end
