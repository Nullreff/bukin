require 'spec_helper'
require 'bukin'
require 'bukin/installer'
require 'bukin/exceptions'

describe Bukin::Installer do
  describe :get_match do
    it 'directly returns a regex' do
      Bukin::Installer::get_match(/something/).should == /something/
    end

    it 'wraps a string with start and end anchors' do
      Bukin::Installer::get_match('something').should == /^something$/
    end

    it 'matches anything for :all' do
      Bukin::Installer::get_match(:all).should == //
    end

    it 'matches .jar files by default' do
      Bukin::Installer::get_match(nil).should == /\.jar$/
    end

    it 'errors when given anything else' do
      expect do
        Bukin::Installer::get_match({})
      end.to raise_error(Bukin::InstallError)

      expect do
        Bukin::Installer::get_match([])
      end.to raise_error(Bukin::InstallError)

      expect do
        Bukin::Installer::get_match(Object.new)
      end.to raise_error(Bukin::InstallError)
    end
  end
end
