require 'spec_helper'
require 'bukin'
require 'fakefs/safe'
require 'yaml'

describe Bukin::Lockfile do

  before(:each) {File.delete(PATH) if File.exist?(PATH)}
  after(:all) {FakeFS.deactivate!}
  before(:all) do
    FakeFS.activate!
    PATH = File.join(Dir.pwd, Bukin::Lockfile::FILE_NAME)
  end

  it 'assignes a default path if none is provided' do
    lockfile = Bukin::Lockfile.new
    lockfile.path.should == PATH
  end

  it 'assignes the path provided in the constructor' do
    lockfile = Bukin::Lockfile.new('/test/path')
    lockfile.path.should == '/test/path'
  end

  it 'loads no resources for an empty or missing file' do
    lockfile = Bukin::Lockfile.new('/non/existant/path')
    lockfile.resources.should == {}
  end

  it 'loads resources from an already existing lockfile' do
    resources = { 'resources' => 'value' }

    File.open(PATH, 'w') {|file| file.write resources.to_yaml}

    lockfile = Bukin::Lockfile.new
    lockfile.resources.should == 'value'
  end

  it 'saves resources to a lockfile' do
    lockfile = Bukin::Lockfile.new
    lockfile.add({
      :name => 'resource_name',
      :version => '1.0.0',
      :files => ['file']
    })
    lockfile.save

    path = File.join
    data = YAML::load_file(PATH)
    data.should == {
      'resources' => {
        'resource_name' => {
          'version' => '1.0.0',
          'files' => ['file']
        }
      }
    }

    File.delete(PATH)
    lockfile = Bukin::Lockfile.new
    lockfile.resources.should == {}
  end

  it 'adds resources to the lockfile' do
    lockfile = Bukin::Lockfile.new
    lockfile.resources.count.should == 0
    lockfile.add({
      :name => 'resource_name',
      :version => '1.0.0',
      :files => ['file1', 'file2']
    })
    lockfile.resources.count.should == 1
    lockfile.resources['resource_name'].should == {
      'version' => '1.0.0', 
      'files' => ['file1', 'file2']
    }
  end
end
