require 'json'
require 'cgi'
require 'bukin/file_match'

module Bukin
  # Api for downloading from jenkins
  class Jenkins
    LATEST = 'lastSuccessfulBuild'
    GOOD_VERSIONS = "'125' or '#{LATEST}'"

    def initialize(url)
      @url = url
    end

    def find_resource(name, version = LATEST, match = FileMatch.any)
      unless self.class.correct_version_format?(version)
        raise VersionError.new(name, version, GOOD_VERSIONS)
      end

      base_path = "#{@url}/job/#{CGI.escape(name)}/#{CGI.escape(version)}"

      info = Bukin.try_get_json("#{base_path}/api/json")
      raise NoDownloadError.new(name, version) unless info 

      download_info = info['artifacts'].find{|file| match =~ file['fileName']}
      raise NoDownloadError.new(name, version) unless download_info

      download = "#{base_path}/artifact/#{download_info['relativePath']}"
      Resource.new(name, info['number'], download)
    end

    def self.correct_version_format?(version)
      version == LATEST || /^[0-9]+$/.match(version)
    end
  end
end
