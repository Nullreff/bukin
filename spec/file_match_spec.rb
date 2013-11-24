require 'spec_helper'
require 'bukin'

describe Bukin::FileMatch do
  it 'matches anything passed to it' do
    match = Bukin::FileMatch.any
    match.should =~ 'filename.jar'
    match.should =~ 'another-file-name.jar'
    match.should =~ 'yet_another.zip'
  end

  it 'matches a string' do
    match = Bukin::FileMatch.new('filename.jar')
    match.should =~ 'filename.jar'
    match.should_not =~ 'another-file-name.jar'
    match.should_not =~ 'yet_another.zip'
  end
   
  it 'matches a regex' do
    match = Bukin::FileMatch.new(/^.*\.jar$/)
    match.should =~ 'filename.jar'
    match.should =~ 'another-file-name.jar'
    match.should_not =~ 'yet_another.zip'
  end

  it 'matches an array of matches' do
    match = Bukin::FileMatch.new(['filename.jar', 'another-file-name.jar'])
    match.should =~ 'filename.jar'
    match.should =~ 'another-file-name.jar'
    match.should_not =~ 'yet_another.zip'
  end

  it 'matches none for other types' do
    match = Bukin::FileMatch.new(:filename)
    match.should_not =~ 'filename.jar'
    match.should_not =~ 'another-file-name.jar'
    match.should_not =~ 'yet_another.zip'
  end
end
