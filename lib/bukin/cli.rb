require 'thor'
require 'bukin/installer'
require 'bukin/bukfile'
require 'bukin/providers/bukget'
require 'bukin/providers/bukkit_dl'
require 'bukin/providers/direct_dl'
require 'bukin/providers/jenkins'

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
    direct_dl = Bukin::DirectDl.new
    jenkins = Bukin::Jenkins.new
    bukkit_dl = Bukin::BukkitDl.new
    bukget = Bukin::Bukget.new

    # Server info
    if direct_dl.usable(server)
      direct_dl.resolve_info(server)
    elsif jenkins.usable(server)
      section "Fetching information from #{jenkins.url(server)}" do
        jenkins.resolve_info(server)
      end
    else
      section "Fetching information from #{bukkit_dl.url}" do
        bukkit_dl.resolve_info(server)
      end
    end

    # Plugins info
    direct_dl_plugins = []
    jenkins_plugins = []
    bukget_plugins = []

    plugins.each do |plugin|
      if direct_dl.usable(plugin)
        direct_dl_plugins << plugin
      elsif jenkins.usable(plugin)
        jenkins_plugins << plugin
      else
        bukget_plugins << plugin
      end
    end

    direct_dl_plugins.each do |plugin|
      direct_dl.resolve_info(plugin)
    end

    jenkins_plugins.each do |plugin|
      section "Fetching information from #{jenkins.url(plugin)}" do
        jenkins.resolve_info(plugin)
      end
    end

    section "Fetching information from #{bukget.url}" do
      bukget_plugins.each do |plugin|
        plugins.each do |plugin|
          plugin[:server] ||= 'craftbukkit'
          begin
            bukget.resolve_info(plugin)
          rescue OpenURI::HTTPError => ex
            raise Bukin::BukinError, "There was an error downloading #{plugin[:name]} (#{plugin[:version]}).\n#{ex.message}"
          end
        end
      end
    end

    # Download and install server and plugins
    installer = Bukin::Installer.new(Dir.pwd, true)

    downloading server[:name], server[:display_version] do
      installer.install(:server, server)
    end

    plugins.each do |plugin|
      downloading plugin[:name], plugin[:version] do
        installer.install(:plugin, plugin)
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

  def downloading(name, version, &block)
    msg = "Downloading #{name}"
    msg << " (#{version})" if version
    section(msg, &block)
  end
end
