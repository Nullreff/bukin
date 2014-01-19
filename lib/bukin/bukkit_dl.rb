require 'json'
require 'cgi'

module Bukin
  # Bukkit download api
  # Docs: http://dl.bukkit.org/about/
  class BukkitDl
    VERSION = 'latest-rb'
    URL = 'http://dl.bukkit.org'
    GOOD_VERSIONS = "'latest', 'latest-rb', 'latest-beta', 'latest-dev', "\
                    "'git-0fd25c4' or 'build-2912'"

    def initialize(url = URL)
      @url = url
    end

    def find(data)
      name = data[:name]
      version = data[:version] || VERSION

      unless correct_version_format?(version)
        raise VersionError.new(name, version, GOOD_VERSIONS)
      end

      info = Bukin.try_get_json(
        "#{@url}/api/1.0/downloads/projects/"\
        "#{CGI.escape(name)}/view/#{CGI.escape(version)}/")

      raise NoDownloadError.new(name, version) unless info

      download = @url + info['file']['url']

      Resource.new(name, "build-#{info['build_number']}", download)
    end

    def correct_version_format?(version)
      'latest' == version ||
      /^latest-(rb|beta|dev)$/ =~ version ||
      /^git-[0-9a-f]{7,40}$/ =~ version ||
      /^build-[0-9]+$/ =~ version
    end
  end
end
