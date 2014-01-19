module Bukin
  # Straight file downloads
  class Download
    def initialize(url)
      @url = url
    end

    def find(name, version = nil, options = {})
      Resource.new(name, version, @url)
    end
  end
end
