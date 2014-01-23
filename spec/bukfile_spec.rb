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

    it "adds a #{type} with the correct jenkins provider" do
      bukfile = Bukin::Bukfile.new do
        send(type, 'resource_name', :jenkins => 'http://example.com')
      end

      bukfile.resources.first[:jenkins].should == 'http://example.com'
    end

    it "adds a #{type} with the correct download link" do
      bukfile = Bukin::Bukfile.new do
        send(type, 'resource_name', :download => 'http://example.com')
      end

      bukfile.resources.first[:download].should == 'http://example.com'
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

  it 'attaches a single group to a resource' do
    bukfile = Bukin::Bukfile.new do
      plugin 'test', group: :test
    end

    bukfile.resources.first[:group].should == [:test]
  end

  it 'attaches multiple groups to a resource' do
    bukfile = Bukin::Bukfile.new do
      plugin 'test', group: [:test, :development]
    end

    bukfile.resources.first[:group].should == [:test, :development]
  end

  it 'attaches a single group to multiple resources' do
    bukfile = Bukin::Bukfile.new do
      group :test do
        plugin 'test1'
        plugin 'test2'
      end
    end

    bukfile.resources[0][:group].should == [:test]
    bukfile.resources[1][:group].should == [:test]
  end

  it 'attaches multiple groups to multiple resources' do
    bukfile = Bukin::Bukfile.new do
      group :test, :development do
        plugin 'test1'
        plugin 'test2'
      end
    end

    bukfile.resources[0][:group].should == [:test, :development]
    bukfile.resources[1][:group].should == [:test, :development]
  end

  it 'attaches groups to multiple resources' do
    bukfile = Bukin::Bukfile.new do
      group :test do
        plugin 'test1', group: :development
        plugin 'test2'
      end
    end

    bukfile.resources[0][:group].should =~ [:test, :development]
    bukfile.resources[1][:group].should == [:test]
  end

  it 'combines duplicate groups' do
    bukfile = Bukin::Bukfile.new do
      group :test do
        plugin 'test1', group: [:development, :test]
        plugin 'test2', group: :test
      end
    end

    bukfile.resources[0][:group].should =~ [:test, :development]
    bukfile.resources[1][:group].should == [:test]
  end

  it 'combines duplicate method groups' do
    bukfile = Bukin::Bukfile.new do
      group :test, :test do
        plugin 'test'
      end
    end

    bukfile.resources.first[:group].should == [:test]
  end

  it 'combines duplicate resource groups' do
    bukfile = Bukin::Bukfile.new do
      plugin 'test', group: [:test, :test]
    end

    bukfile.resources.first[:group].should == [:test]
  end

  it 'only adds groups inside a block' do
    bukfile = Bukin::Bukfile.new do
      group :development do
        plugin 'test1'
      end
      plugin 'test2'
    end

    bukfile.resources[0][:group].should == [:development]
    bukfile.resources[1][:group].should == []
  end

  it 'throws an error when groups are nested' do
    expect do
      Bukin::Bukfile.new do
        group :test do
          group :development do
            plugin 'test'
          end
        end
      end
    end.to raise_error(Bukin::BukfileError)
  end

  it 'throws an error when group is not a symbol' do
    expect do
      Bukin::Bukfile.new do
        group 'test' do
          plugin 'test'
        end
      end
    end.to raise_error(Bukin::BukfileError)
  end

  it 'throws an error when resource group is not a symbol' do
    expect do
      Bukin::Bukfile.new do
        plugin 'test', group: 'test'
      end
    end.to raise_error(Bukin::BukfileError)
  end
end
