require 'spec_helper'
require 'bukin'

describe Bukin::Bukfile do
  [:server, :plugin].each do |type|

    it "adds a #{type} by method" do
      bukfile = Bukin::Bukfile.new{}
      bukfile.resources.size.should == 0

      bukfile.send(type, '')
      bukfile.resources.size.should == 1
    end

    it "adds a #{type} by constructor" do
      bukfile = Bukin::Bukfile.new do
        send(type, '')
      end

      bukfile.resources.size.should == 1
    end

    it "adds a #{type} with the correct name" do
      bukfile = Bukin::Bukfile.new do
        send(type, 'resource_name')
      end

      bukfile.resources.first[:name].should == 'resource_name'
    end

    it "adds a #{type} with the correct path" do
      bukfile = Bukin::Bukfile.new do
        send(type, 'resource_name')
      end

      resource = bukfile.resources.first
      case type
      when :server
        resource[:path].should == '.'
      when :plugin
        resource[:path].should == 'plugins'
      end
    end

    it "adds a #{type} with the correct version" do
      bukfile = Bukin::Bukfile.new do
        send(type, '', '1.0.0')
      end

      bukfile.resources.first[:version].should == '1.0.0'
    end
  end

  it 'adds both plugins and servers' do
    bukfile = Bukin::Bukfile.new do
      server 'craftbukkit'
      plugin 'worldedit'
    end

    bukfile.resources.size.should == 2
    bukfile.resources.find{|resource| resource[:name] == 'craftbukkit'}.should_not be_nil
    bukfile.resources.find{|resource| resource[:name] == 'worldedit'}.should_not be_nil
  end

  it 'will not add non-existant resources' do
    bukfile = Bukin::Bukfile.new do
    end

    bukfile.resources.size.should == 0
    bukfile.resources.find{|resource| resource[:name] == 'missing_plugin'}.should be_nil
  end
end
