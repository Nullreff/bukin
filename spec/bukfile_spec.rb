require 'spec_helper'
require 'bukin'

describe Bukin::Bukfile do
  [:server, :plugin].each do |type|

    it "adds a #{type} by method" do
      bukfile = Bukin::Bukfile.new{}
      bukfile.resources.size.should == 0

      bukfile.send(type, 'resource_name')
      bukfile.resources.size.should == 1
    end

    it "adds a #{type} by constructor" do
      bukfile = Bukin::Bukfile.new do
        send(type, 'resource_name')
      end

      bukfile.resources.size.should == 1
    end

    it "adds a #{type} with the correct name" do
      bukfile = Bukin::Bukfile.new do
        send(type, 'resource_name')
      end

      bukfile.resources.first[:name].should == 'resource_name'
    end

    it "adds a #{type} with the correct type" do
      bukfile = Bukin::Bukfile.new do
        send(type, 'resource_name')
      end

      resource = bukfile.resources.first[:type].should == type
    end

    it "adds a #{type} with the correct version" do
      bukfile = Bukin::Bukfile.new do
        send(type, 'resource_name', '1.0.0')
      end

      bukfile.resources.first[:version].should == '1.0.0'
    end

    it "will not add the same #{type} more than once" do
      expect do
        bukfile = Bukin::Bukfile.new do
          send(type, 'duplicate_resource')
          send(type, 'duplicate_resource')
        end
      end.to raise_error(Bukin::BukinError)
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
