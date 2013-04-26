require 'bukin/utils'
require 'json'
require 'cgi'

# BukGet api
# Docs: http://bukget.org/pages/docs/API3.html
class Bukin::Bukget
  attr_reader :url

  def initialize(url = 'http://api.bukget.org')
    @url = url
  end

  def api_url
    "#{url}/3"
  end

  def resolve_info(data)
    return data if data[:download]

    name = data[:name]
    version = data[:version] || 'latest'
    server = data[:server]
    server = 'bukkit' if server == 'craftbukkit'

    url = "#{api_url}/plugins/#{CGI.escape(server)}/#{CGI.escape(name)}/#{CGI.escape(version)}"
    info = JSON.parse(open(url).read)

    versions = info['versions']
    if versions.empty?
      raise Bukin::InstallError, "The plugin #{name} (#{version}) has no available downloads from BukGet."
    end

    version_data = versions.find {|version_data| jar_extension?(version_data)}
    if version_data
      data[:version] = version_data['version']
      data[:download] = version_data['download']
    else
      puts info
      raise Bukin::InstallError, "The plugin #{name} (#{version}) has no jar files available for download"
    end

    data
  end

  def jar_extension?(version_data)
    File.extname(version_data['filename']) == '.jar'
  end

end
