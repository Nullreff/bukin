require 'spec_helper'
require 'bukin'

ONE_RESOURCE = {
  'versions' => [
    {
      'version' => '1.0.0',
      'download' => 'http://download/resource.jar',
      'filename' => 'resource.jar'
    }
  ]
}

TWO_RESOURCES = {
  'versions' => [
    {
      'version' => '1.0.0',
      'download' => 'http://download/resource1.jar',
      'filename' => 'resource1.jar'
    },
    {
      'version' => '1.0.0',
      'download' => 'http://download/resource2.jar',
      'filename' => 'resource2.jar'
    }
  ]
}

TWO_FILETYPES = {
  'versions' => [
    {
      'version' => '1.0.0',
      'download' => 'http://download/resource.zip',
      'filename' => 'resource.zip'
    },
    {
      'version' => '1.0.0',
      'download' => 'http://download/resource.jar',
      'filename' => 'resource.jar'
    }
  ]
}

describe Bukin::Bukget do
  it 'installs the latest version of a resource' do
    Bukin.should_receive(:get_json)
         .with('http://api.bukget.org/3/plugins/bukkit/resource/release')
         .and_return(ONE_RESOURCE)

    bukget = Bukin::Bukget.new
    resource = bukget.find_resource('resource')

    resource.name.should == 'resource'
    resource.version.should == '1.0.0'
    resource.download.should == 'http://download/resource.jar'
  end

  it 'installs a specific version of a resource' do
    Bukin.should_receive(:get_json)
         .with('http://api.bukget.org/3/plugins/bukkit/resource/1.0.0')
         .and_return(ONE_RESOURCE)

    bukget = Bukin::Bukget.new
    resource = bukget.find_resource('resource', '1.0.0')

    resource.name.should == 'resource'
    resource.version.should == '1.0.0'
    resource.download.should == 'http://download/resource.jar'
  end

  it 'returns an error when asked for a resource that doese not exist' do
    Bukin.should_receive(:get_json) { raise OpenURI::HTTPError.new(nil, nil) }

    bukget = Bukin::Bukget.new
    expect { bukget.find_resource('') }.to raise_error(Bukin::NoDownloadError)
  end

  it 'chooses the first version when there are multiple versions' do
    Bukin.should_receive(:get_json)
         .with('http://api.bukget.org/3/plugins/bukkit/resource/1.0.0')
         .and_return(TWO_RESOURCES)

    bukget = Bukin::Bukget.new
    resource = bukget.find_resource('resource', '1.0.0')

    resource.download.should == 'http://download/resource1.jar'
  end

  it 'chooses the version with a .jar file when there are multiple versions' do
    Bukin.should_receive(:get_json)
         .with('http://api.bukget.org/3/plugins/bukkit/resource/1.0.0')
         .and_return(TWO_FILETYPES)

    bukget = Bukin::Bukget.new
    resource = bukget.find_resource('resource', '1.0.0')

    resource.download.should == 'http://download/resource.jar'
  end
end
