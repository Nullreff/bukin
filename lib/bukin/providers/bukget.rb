require 'bukin/utils'
require 'json'

# BukGet api
# Docs: http://bukget.org/pages/docs/API3.html
BUKGET_API = "http://api.bukget.org/3"

class Bukin::Bukget
  attr_accessor :api_url

  def initialize(url = BUKGET_API)
    @api_url = url
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
