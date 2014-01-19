require 'spec_helper'
require 'bukin'

describe Bukin::BukkitDl, :vcr do
  before do
    @name = 'craftbukkit'
    @version = 'build-2912'
    @download = 'http://dl.bukkit.org/downloads/craftbukkit/get/'\
                '02381_1.6.4-R1.0/craftbukkit.jar'
    @missing_name = 'missing-name'
    @missing_version = 'build-0000'
    @missing_file = 'missing-file.jar'
    @latest_version = 'build-2918'
  end

  it 'installs the latest version of a resource' do
    provider = Bukin::BukkitDl.new
    version, download = provider.find(name: @name)

    version.should == @latest_version
  end

  it 'installs a specific version of a resource' do
    provider = Bukin::BukkitDl.new
    version, download = provider.find(name: @name, version: @version)

    version.should == @version
  end

  it 'returns an error when asked for a resource that doese not exist' do
    provider = Bukin::BukkitDl.new
    expect do
      provider.find(name: @missing_name)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'returns an error when asked for a version that doese not exist' do
    provider = Bukin::BukkitDl.new
    expect do
      provider.find(name: @name, version: @missing_version)
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'chooses the first file when there are multiple files' do
    provider = Bukin::BukkitDl.new
    version, download = provider.find(name: @name, version: @version)

    download.should == @download
  end
end
