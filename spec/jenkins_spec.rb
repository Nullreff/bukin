require 'spec_helper'
require 'bukin'
require 'bukin/file_match'

describe Bukin::Jenkins, :vcr do
  before do
    # Sorry md_5, but I'm using you for my integration tests
    @url = 'http://ci.md-5.net'
    @name = 'spigot'
    @version = '1000'
    @download = 'http://ci.md-5.net/job/spigot/1000/artifact/Spigot-Server/'\
                'target/spigot-1.6.1-R0.1-SNAPSHOT.jar'
    @missing_name = 'missing-name'
    @missing_version = '99999999'
    @missing_file = 'missing-file.jar'
    @latest_version = '1136'
    end

  it 'installs the latest version of a resource' do
    provider = Bukin::Jenkins.new(@url)
    resource = provider.find_resource(@name)

    resource.name.should == @name
    resource.version.should == @latest_version
  end

  it 'installs a specific version of a resource' do
    provider = Bukin::Jenkins.new(@url)
    resource = provider.find_resource(@name, @version)

    resource.name.should == @name
    resource.version.should == @version
    resource.download.should == @download
  end

  it 'returns an error when asked for a resource that doese not exist' do
    provider = Bukin::Jenkins.new(@url)
    expect do
      provider.find_resource(@missing_name)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'returns an error when asked for a version that does not exist' do
    provider = Bukin::Jenkins.new(@url)
    expect do
      provider.find_resource(@name, @missing_version)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'returns an error when asked for a file that does not exist' do
    provider = Bukin::Jenkins.new(@url)
    expect do
      provider.find_resource(@name, @version, @missing_file)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'chooses the first file when there are multiple files' do
    provider = Bukin::Jenkins.new(@url)
    resource = provider.find_resource(@name, @version)

    resource.download.should == @download
  end
end