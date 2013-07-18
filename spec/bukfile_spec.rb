require 'spec_helper'
require 'bukin'

describe Bukin::Bukfile do
  it 'adds a server' do
    bukfile = Bukin::Bukfile.new do
      server 'craftbukkit'
    end

    server = bukfile.resources.first
    server[:name].should == 'craftbukkit'
    server[:path].should == '.'
  end

  it 'adds a plugin' do
    bukfile = Bukin::Bukfile.new do
      plugin 'worldedit'
    end

    plugin = bukfile.resources.first
    plugin[:name].should == 'worldedit'
    plugin[:path].should == 'plugins'
  end

  it 'adds a server with a version' do
    bukfile = Bukin::Bukfile.new do
      server 'craftbukkit', '1.0.0'
    end

    server = bukfile.resources.first
    server[:name].should == 'craftbukkit'
    server[:version].should == '1.0.0'
  end

  it 'adds a plugin with a version' do
    bukfile = Bukin::Bukfile.new do
      plugin 'worldedit', '1.0.0'
    end

    plugin = bukfile.resources.first
    plugin[:name].should == 'worldedit'
    plugin[:version].should == '1.0.0'
  end
end
