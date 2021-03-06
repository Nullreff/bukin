require 'json'
require 'cgi'
require 'bukin/file_match'
require 'bukin/resource'

module Bukin
  # BukGet api
  # Docs: http://bukget.org/pages/docs/API3.html
  class Bukget
    attr_reader :url, :server

    VERSION = 'release'
    URL = 'http://api.bukget.org'
    SERVER = 'bukkit'

    def initialize(url = URL, server = SERVER)
      @url = url
      @server = server
    end

    def find(data)
      name = data[:name]
      version = data[:version] || VERSION
      match = data[:file] ? FileMatch.new(data[:file]) : FileMatch.any

      info = Bukin.try_get_json("#{@url}/3/plugins/#{CGI.escape(@server)}/"\
                            "#{CGI.escape(name)}/#{CGI.escape(version)}")

      raise NoDownloadError.new(name, version) unless info

      versions = info['versions']

      if versions.nil? || versions.empty?
        # A couple of plugins don't update the 'version' field correctly but
        # do update the 'dbo_version' field.  This attempts to find a
        # downloadable version with the correct 'dbo_version' field
        info = Bukin.get_json("#{@url}/3/plugins/#{CGI.escape(@server)}/"\
                              "#{CGI.escape(name)}")
        versions = info['versions'].select do |data|
          data['dbo_version'] == version
        end

        raise NoDownloadError.new(name, version) if versions.empty?
      end

      # Filter out any plugins that don't match our file name
      versions = versions.select{|data| match =~ data['filename']}

      # Some people release two of the same version on bukkit dev,
      # one as a zip package and one with the jar only.
      # This downloads the jar only version by default.
      version_data = versions.find {|data| jar_filename(data)} || versions.first
      raise NoDownloadError.new(name, version) unless version_data

      return version_data['version'], version_data['download']
    end

  private
    def jar_filename(data)
        File.extname(data['filename']) == '.jar'
    end
  end
end
