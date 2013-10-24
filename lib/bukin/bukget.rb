require 'json'
require 'cgi'

module Bukin
  # BukGet api
  # Docs: http://bukget.org/pages/docs/API3.html
  class Bukget < Provider
    @name = :bukget
    @default_url = 'http://api.bukget.org'
    @default_version = 'latest'

    def resolve_info
      url = "#{data[:bukget]}/3/plugins/#{CGI.escape(server)}"\
            "/#{CGI.escape(name)}/#{CGI.escape(version)}"
      info = JSON.parse(open(url).read)

      versions = info['versions']
      if versions.empty?
        raise Bukin::InstallError, 
          "The plugin #{name} (#{version}) has no available downloads from BukGet"
      end

      # Some people release two of the same version on bukkit dev,
      # one as a zip package and one with the jar only.
      # This downloads the jar only version by default.
      version_data = versions.find do |version_data|
        File.extname(version_data['filename']) == '.jar'
      end || versions.first

      data[:version] = version_data['version']
      data[:download] = version_data['download']
      data
    end

  private
    def server
      if data[:server].nil? || data[:server] == 'craftbukkit'
        'bukkit'
      else
        data[:server]
      end
    end
  end
end
