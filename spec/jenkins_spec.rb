require 'spec_helper'
require 'bukin'
require 'bukin/file_match'

describe Bukin::Jenkins, :vcr do
  before do
    # Sorry md_5, but I'm using you for my integration tests
    @url = 'http://ci.md-5.net'
    @name = 'spigot'
    @version = 'build-1000'
    @download = 'http://ci.md-5.net/job/spigot/1000/artifact/Spigot-Server/'\
                'target/spigot-1.6.1-R0.1-SNAPSHOT.jar'
    @missing_name = 'missing-name'
    @missing_version = 'build-99999999'
    @missing_file = 'missing-file.jar'
    @latest_version = 'build-1136'
  end

  it 'installs the latest version of a resource' do
    provider = Bukin::Jenkins.new(@url)
    version, download = provider.find(name: @name)

    version.should == @latest_version
  end

  it 'installs a specific version of a resource' do
    provider = Bukin::Jenkins.new(@url)
    version, download = provider.find(name: @name, version: @version)

    version.should == @version
    download.should == @download
  end

  it 'returns an error when asked for a resource that doese not exist' do
    provider = Bukin::Jenkins.new(@url)
    expect do
      provider.find(name: @missing_name)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'returns an error when asked for a version that does not exist' do
    provider = Bukin::Jenkins.new(@url)
    expect do
      provider.find(name: @name, version: @missing_version)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'returns an error when asked for a file that does not exist' do
    provider = Bukin::Jenkins.new(@url)
    expect do
      provider.find(name: @name, version: @version, file: @missing_file)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'chooses the first file when there are multiple files' do
    provider = Bukin::Jenkins.new(@url)
    version, download = provider.find(name: @name, version: @version)

    download.should == @download
  end
end
