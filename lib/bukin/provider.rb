require 'json'

module Bukin
  class Provider
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

    class << self
      attr_accessor :default_version, :default_url
    end
  end
end
