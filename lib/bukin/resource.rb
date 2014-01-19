module Bukin
  class Resource
    attr_reader :type, :name, :version, :download

    def initialize(data, version, download)
      @type = data[:type]
      @name = data[:name]
      @version = version
      @download = download
      @data = data
    end

    def [](key)
      @data[key]
    end
  end
end
