require 'spec_helper'
require 'bukin'

describe Bukin::Bukget, :vcr do
  before do
    @name = 'worldedit'
    @version = '5.5.8'
    @missing_name = 'missing-name'
  end

  it 'installs the latest version of a resource' do
    bukget = Bukin::Bukget.new
    resource = bukget.find_resource(@name)

    resource.name.should == @name
  end

  it 'installs a specific version of a resource' do
    bukget = Bukin::Bukget.new
    resource = bukget.find_resource(@name, @version)

    resource.name.should == @name
    resource.version.should == @version
  end

  it 'returns an error when asked for a resource that doese not exist' do
    bukget = Bukin::Bukget.new
    expect do
      bukget.find_resource(@missing_name)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'chooses the version with a .jar file when there are multiple versions' do
    bukget = Bukin::Bukget.new
    resource = bukget.find_resource(@name, @version)

    resource.download.should == 'http://dev.bukkit.org/media/files/739/931/worldedit-5.5.8.jar'
  end
end
