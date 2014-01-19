require 'json'
require 'cgi'
require 'bukin/file_match'

module Bukin
  # Api for downloading from jenkins
  class Jenkins
    VERSION = 'lastSuccessfulBuild'
    GOOD_VERSIONS = "'125' or '#{VERSION}'"

    def initialize(url)
      @url = url
    end

    def find(data)
      name = data[:name]
      version = data[:version] || VERSION
      match = data[:file] ? FileMatch.new(data[:file]) : FileMatch.any

      unless correct_version_format?(version)
        raise VersionError.new(name, version, GOOD_VERSIONS)
      end

      base_path = "#{@url}/job/#{CGI.escape(name)}/#{CGI.escape(version)}"

      info = Bukin.try_get_json("#{base_path}/api/json")
      raise NoDownloadError.new(name, version) unless info 

      download_info = info['artifacts'].find{|file| match =~ file['fileName']}
      raise NoDownloadError.new(name, version) unless download_info

      download = "#{base_path}/artifact/#{download_info['relativePath']}"
      Resource.new(name, info['number'].to_s, download)
    end

  private
    def correct_version_format?(version)
      version == VERSION || /^[0-9]+$/.match(version)
    end
  end
end
