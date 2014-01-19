require 'spec_helper'
require 'fakefs/safe'
require 'bukin'
require 'bukin/cli'

# Taken from https://github.com/barroncraft/minecraft-dota/
#
BUKFILE = 
%q{server 'Spigot-1.7', 'build-14', :jenkins => 'http://ci.md-5.net', :file => /spigot\.jar/
plugin 'banvote', '0.1.1.1'
plugin 'commandbook', '2.2'
plugin 'commandhelper', '3.3.0'
plugin 'deathcontrol', '1.87'
plugin 'minequery', '1.5', :download => 'http://repository.barroncraft.com/downloads/MineQuery-Barroncraft.jar'
plugin 'nocheatplus', '3.10.3-RC-sMD5NET-b626'
plugin 'permissionsex', '1.20.1'
plugin 'shopkeepers', '1.14.2', :download => 'http://dev.bukkit.org/media/files/716/304/Shopkeepers.jar'
plugin 'simpleclans', '2.3.4'
plugin 'simpleclansextensions', '3.6', :download => 'http://repository.barroncraft.com/downloads/SimpleClansExtensions-v3.6.jar'
plugin 'spectate', '2.0'
plugin 'tag', '2.6'
plugin 'vanish', '3.18.1'
plugin 'vault', '1.2.17-b224'
plugin 'worldborder', '1.6.1'
plugin 'worldedit', '5.5.5'
plugin 'worldguard', '5.7.3'
plugin 'pvp-kill-announcer', '3.0'
plugin 'colorme', '3.8.1'
plugin 'fulljoinvip', '1.3'
plugin 'command-signs', '1.9.1.1'
plugin 'pluginreloader', '1.3.1'
plugin 'loginsecurity', '2.0.4'}

describe Bukin::CLI, :vcr do
  before(:all) {FakeFS.activate!}
  after(:all) {FakeFS.deactivate!}

  # If this passes, it probably works ;)
  it 'Installs plugins from a bukfile' do
     File.open(Bukin::Bukfile::FILE_NAME, 'w') do |file|
       file.write(BUKFILE)
     end
     Dir.mkdir('plugins')

     Bukin::CLI.new.install
  end
end

