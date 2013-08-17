require 'json'

class Provider
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def name
    data[:name]
  end

  def version
    data[:version] || DEFAULT_VERSION
  end
end
