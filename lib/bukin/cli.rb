require 'thor'
require 'bukin/installer'
require 'bukin/bukfile'
require 'bukin/providers/bukget'
require 'bukin/providers/bukkit_dl'

class Bukin::CLI < Thor

  desc 'install', "Download and install the resources specified in a Bukfile"
  def install
    # Parse in the Bukfile
    bukfile = section 'Parsing Bukfile' do
      Bukin::Bukfile.from_file
    end

    server = bukfile.server_info
    plugins = bukfile.plugins_info

    # Grab information from the various providers
    bukkit_dl = Bukin::BukkitDl.new
    bukget = Bukin::Bukget.new

    section "Fetching information from #{bukkit_dl.url}" do
      bukkit_dl.resolve_info(server)
    end

    section "Fetching information from #{bukget.url}" do
      plugins.map do |plugin|
        plugin[:server] ||= server[:name]
        bukget.resolve_info(plugin)
      end
    end

    # Download and install server and plugins
    installer = Bukin::Installer.new(Dir.pwd, true)

    section "Downloading #{server[:name]} (#{server[:display_version]})" do
      installer.install(:server, bukkit_dl, server)
    end

    plugins.each do |plugin|
      section "Downloading #{plugin[:name]} (#{plugin[:version]})" do
        installer.install(:plugin, bukget, plugin)
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
    value = yield
    say 'Done', :green
    value
  rescue => ex
    say 'Error', :red
    raise ex
  end
end
