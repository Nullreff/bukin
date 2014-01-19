require 'json'
require 'cgi'
require 'bukin/file_match'

module Bukin
  # Api for downloading from jenkins
  class Jenkins
    attr_reader :url

    VERSION = 'lastSuccessfulBuild'
    GOOD_VERSIONS = "'build-125'"

    def initialize(url)
      @url = url
    end

    def find(data)
      name = data[:name]
      version = data[:version]
      match = data[:file] ? FileMatch.new(data[:file]) : FileMatch.any

      if version.nil? || version == VERSION
        build = VERSION
      elsif correct_version_format?(version)
        build = version[/^build-([0-9]+)$/, 1] 
      else 
        raise VersionError.new(name, version, GOOD_VERSIONS)
      end

      base_path = "#{@url}/job/#{CGI.escape(name)}/#{CGI.escape(build)}"

      info = Bukin.try_get_json("#{base_path}/api/json")
      raise NoDownloadError.new(name, version) unless info 

      download_info = info['artifacts'].find{|file| match =~ file['fileName']}
      raise NoDownloadError.new(name, version) unless download_info

      download = "#{base_path}/artifact/#{download_info['relativePath']}"
      return "build-#{info['number']}", download
    end

  private
    def correct_version_format?(version)
      version == VERSION || /^build-[0-9]+$/.match(version)
    end
  end
end
