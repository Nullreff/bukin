require 'spec_helper'
require 'bukin'

describe Bukin::Bukget, :vcr do
  before do
    @name = 'worldedit'
    @version = '5.5.8'
    @download = 'http://dev.bukkit.org/media/files/739/931/worldedit-5.5.8.jar'
    @missing_name = 'missing-name'
    @missing_version = '0.0.0'
    @missing_file = 'missing-file.jar'
    @latest_version = '5.5.8'
  end

  it 'installs the latest version of a resource' do
    provider = Bukin::Bukget.new
    resource = provider.find(name: @name)

    resource.name.should == @name
    resource.version.should == @latest_version
  end

  it 'installs a specific version of a resource' do
    provider = Bukin::Bukget.new
    resource = provider.find(name: @name, version: @version)

    resource.name.should == @name
    resource.version.should == @version
  end

  it 'returns an error when asked for a resource that doese not exist' do
    provider = Bukin::Bukget.new
    expect do
      provider.find(name: @missing_name)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'returns an error when asked for a version that doese not exist' do
    provider = Bukin::Bukget.new
    expect do
      provider.find(name: @name, version: @missing_version)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'returns an error when asked for a file that does not exist' do
    provider = Bukin::Bukget.new
    expect do
      provider.find(name: @name, version: @version, file: @missing_file)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'chooses the version with a .jar file when there are multiple versions' do
    provider = Bukin::Bukget.new
    resource = provider.find(name: @name, version: @version)

    resource.download.should == @download
  end
end
