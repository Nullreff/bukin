require 'json'

class Bukin::Provider
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def name
    data[:name]
  end

  def version
    data[:version] || default_version
  end
end
