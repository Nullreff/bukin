require 'spec_helper'
require 'bukin'
require 'bukin/file_match'

ONE_PLUGIN = {
  'artifacts' => [
    { 'fileName' => 'resource.jar', 'relativePath' => 'resource.jar' }
  ],
  'number' => '123'
}

TWO_PLUGINS = {
  'artifacts' => [
    { 'fileName' => 'resource1.jar', 'relativePath' => 'resource1.jar' },
    { 'fileName' => 'resource2.jar', 'relativePath' => 'resource2.jar' }
  ],
  'number' => '123'
}

describe Bukin::Jenkins do
  it 'installs the latest version of a resource' do
    Bukin.should_receive(:get_json)
         .with('http://jenkins/job/resource/lastSuccessfulBuild/api/json')
         .and_return(ONE_PLUGIN)

    bukget = Bukin::Jenkins.new('http://jenkins')
    resource = bukget.find_resource('resource')

    resource.name.should == 'resource'
    resource.version.should == '123'
    resource.download.should == 'http://jenkins/job/resource/lastSuccessfulBuild/artifact/resource.jar'
  end

  it 'installs a specific version of a resource' do
    Bukin.should_receive(:get_json)
         .with('http://jenkins/job/resource/123/api/json')
         .and_return(ONE_PLUGIN)

    bukget = Bukin::Jenkins.new('http://jenkins')
    resource = bukget.find_resource('resource', '123')

    resource.name.should == 'resource'
    resource.version.should == '123'
    resource.download.should == 'http://jenkins/job/resource/123/artifact/resource.jar'
  end

  it 'returns an error when asked for a resource that doese not exist' do
    Bukin.should_receive(:get_json) { raise OpenURI::HTTPError.new(nil, nil) }

    bukget = Bukin::Jenkins.new('http://jenkins')
    expect { bukget.find_resource('') }.to raise_error(Bukin::NoDownloadError)
  end

  it 'returns an error when asked for a file that does not exist' do
    Bukin.should_receive(:get_json)
         .with('http://jenkins/job/resource/123/api/json')
         .and_return(ONE_PLUGIN)

    bukget = Bukin::Jenkins.new('http://jenkins')
    expect do
      bukget.find_resource('resource', '123', Bukin::FileMatch.new('bad-name.jar'))
    end.to raise_error(Bukin::NoDownloadError)
  end

  it 'chooses the first file when there are multiple files' do
    Bukin.should_receive(:get_json)
         .with('http://jenkins/job/resource/123/api/json')
         .and_return(TWO_PLUGINS)

    bukget = Bukin::Jenkins.new('http://jenkins')
    resource = bukget.find_resource('resource', '123')

    resource.download.should == 'http://jenkins/job/resource/123/artifact/resource1.jar'
  end
end
