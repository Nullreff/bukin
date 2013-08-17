require 'json'
require 'cgi'

# BukGet api
# Docs: http://bukget.org/pages/docs/API3.html
class Bukin::Bukget < Provider
  DEFAULT_URL = 'http://api.bukget.org'
  DEFAULT_VERSION = 'latest'

  def resolve_info
    info = JSON.parse(open(url).read)
    versions = info['versions']
    if versions.empty?
      raise Bukin::InstallError, "The plugin #{name} (#{version}) has no available downloads from BukGet."
    end

    # Some people release two of the same version on bukkit
    # dev, one as a zip package and one with the jar only.
    # This downloads the jar only version by default.
    version_data = versions.find {|version_data| jar_extension?(version_data)} || versions.first
    data[:version] =  version_data['version']
    data[:download] = version_data['download']
    data
  end

  def url
    "#{data[:bukget]}/3/plugins/#{CGI.escape(server)}/#{CGI.escape(name)}/#{CGI.escape(version)}"
  end

private
  def server
    if data[:server].nil? || data[:server] == 'craftbukkit'
      'bukkit'
    else
      data[:server]
    end
  end

  def jar_extension?(version_data)
    File.extname(version_data['filename']) == '.jar'
  end
end
