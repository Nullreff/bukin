require 'spec_helper'
require 'bukin/state'
require 'fakefs/safe'
require 'fileutils'
require 'yaml'

describe Bukin::State do
  before(:all) do
    FakeFS.activate!
    @path = Bukin::State.new.path
  end

  before(:each) {FileUtils.rm_r(@path) if Dir.exist?(@path)}
  after(:all) {FakeFS.deactivate!}

  it 'assignes a default path if none is provided' do
    state = Bukin::State.new
    state.path.should == @path
  end

  it 'assignes the path provided in the constructor' do
    state = Bukin::State.new('/test/path')
    state.path.should == '/test/path/.bukin'
  end
  
  it 'stores files by their name and version' do
    state = Bukin::State.new
    state.files['worldguard', '1.0.0'] = ['plugins/WorldGuard.jar']

    state.files['worldguard'].should == { '1.0.0' => ['plugins/WorldGuard.jar'] }
  end

  it 'saves files to a yaml file' do
    state = Bukin::State.new
    state.files['worldguard', '1.0.0'] = ['plugins/WorldGuard.jar']
    state.save

    data = YAML::load_file(File.join(state.path,'files.yml'))
    data.should == { 'worldguard' => { '1.0.0' => ['plugins/WorldGuard.jar'] } }
  end

  it 'loads files from a yaml file' do
    data = { 'worldguard' => { '1.0.0' => ['plugins/WorldGuard.jar'] } }
    FileUtils.mkdir_p(@path)
    File.open(File.join(@path, 'files.yml'), 'w') {|file| file.write data.to_yaml}

    state = Bukin::State.new
    state.files['worldguard', '1.0.0'].should == ['plugins/WorldGuard.jar']
  end

  it 'checks for already instaled files' do
    FileUtils.mkdir_p('plugins')
    FileUtils.touch('plugins/WorldGuard.jar')

    state = Bukin::State.new
    state.files['worldguard', '1.0.0'] = ['plugins/WorldGuard.jar']

    state.files.installed?('worldguard', '1.0.0').should be_true
  end

  it 'removes old installed files' do
    FileUtils.mkdir_p('plugins')
    FileUtils.touch('plugins/WorldGuard.jar')

    state = Bukin::State.new
    state.files['worldguard', '1.0.0'] = ['plugins/WorldGuard.jar']
    state.files.delete('worldguard')

    File.exist?('plugins/WorldGuard.jar').should be_false
    state.files['worldguard', '1.0.0'].should be_nil
  end
end
