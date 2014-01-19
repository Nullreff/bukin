module Bukin
  # Straight file downloads
  class Download
    attr_accessor :url

    def initialize(url)
      @url = url
    end

    def find(data)
      version = data[:version]

      return version, @url
    end
  end
end
