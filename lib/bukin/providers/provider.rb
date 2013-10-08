require 'json'

class Bukin::Provider
  attr_reader :data

  def self.default_version(version)
    @@default_version = version
  end

  def self.default_url(url)
    @@default_url = url
  end

  def initialize(data)
    @data = data
  end

  def name
    data[:name]
  end

  def version
    data[:version] || @@default_version
  end
end
