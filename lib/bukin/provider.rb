require 'json'

module Bukin
  class Provider
    class << self
      attr_reader :name, :default_version, :default_url
    end
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
end
