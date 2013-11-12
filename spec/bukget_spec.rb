require 'spec_helper'
require 'bukin'

ONE_PLUGIN = {
  'versions' => [
    {
      'version' => '1.0.0',
      'download' => 'http://download/',
      'filename' => 'plugin.jar'
    }
  ]
}

TWO_PLUGINS = {
  'versions' => [
    {
      'version' => '1.0.0',
      'download' => 'http://download/plugin1.jar',
      'filename' => 'plugin1.jar'
    },
    {
      'version' => '1.0.0',
      'download' => 'http://download/plugin2.jar',
      'filename' => 'plugin2.jar'
    }
  ]
}

TWO_FILETYPES = {
  'versions' => [
    {
      'version' => '1.0.0',
      'download' => 'http://download/plugin.zip',
      'filename' => 'plugin.zip'
    },
    {
      'version' => '1.0.0',
      'download' => 'http://download/plugin.jar',
      'filename' => 'plugin.jar'
    }
  ]
}

describe Bukin::Bukget do
  it 'installs the latest version of a plugin' do
    Bukin.should_receive(:get_json)
         .with('http://api.bukget.org/3/plugins/bukkit/plugin/release')
         .and_return(ONE_PLUGIN)

    bukget = Bukin::Bukget.new
    resource = bukget.find_resource('plugin')

    resource.name.should == 'plugin'
    resource.version.should == '1.0.0'
    resource.download.should == 'http://download/'
  end

  it 'installs a specific version of a plugin' do
    Bukin.should_receive(:get_json)
         .with('http://api.bukget.org/3/plugins/bukkit/plugin/1.0.0')
         .and_return(ONE_PLUGIN)

    bukget = Bukin::Bukget.new
    resource = bukget.find_resource('plugin', '1.0.0')

    resource.name.should == 'plugin'
    resource.version.should == '1.0.0'
    resource.download.should == 'http://download/'
  end

  it 'returns an error when asked for a plugin that doese not exist' do
    Bukin.should_receive(:get_json) { raise OpenURI::HTTPError.new(nil, nil) }

    bukget = Bukin::Bukget.new
    expect { bukget.find_resource('') }.to raise_error(Bukin::NoDownloadError)
  end

  it 'chooses the first version when there are multiple versions' do
    Bukin.should_receive(:get_json)
         .with('http://api.bukget.org/3/plugins/bukkit/plugin/1.0.0')
         .and_return(TWO_PLUGINS)

    bukget = Bukin::Bukget.new
    resource = bukget.find_resource('plugin', '1.0.0')

    resource.download.should == 'http://download/plugin1.jar'
  end

  it 'chooses the version with a .jar file when there are multiple versions' do
    Bukin.should_receive(:get_json)
         .with('http://api.bukget.org/3/plugins/bukkit/plugin/1.0.0')
         .and_return(TWO_FILETYPES)

    bukget = Bukin::Bukget.new
    resource = bukget.find_resource('plugin', '1.0.0')

    resource.download.should == 'http://download/plugin.jar'
  end
end
