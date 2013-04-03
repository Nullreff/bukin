require 'bukin/utils'
require 'json'

# BukGet api
# Docs: http://bukget.org/pages/docs/API3.html
class Bukin::Bukget
  attr_reader :api_url

  def initialize(url = 'http://api.bukget.org')
    @api_url = "#{url}/3"
  end

  def download(name, version, server)
    server = 'bukkit' if server == 'craftbukkit'
    url = "#{@api_url}/plugins/#{server}/#{name}/#{version}/download"
    download_file(url, true)
  end

  def info(name, version, server)
    server = 'bukkit' if server == 'craftbukkit'
    url = "#{@api_url}/plugins/#{server}/#{name}/#{version}"
    JSON.parse(open(url).read)
  end

  def resolve_version(name, version, server)
    info(name, version, server)['versions'][0]['version']
  end
end
