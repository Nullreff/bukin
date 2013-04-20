require 'bukin/utils'
require 'json'

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
    return if data[:download]

    name = data[:name]
    version = data[:version]
    server = data[:server]
    server = 'bukkit' if server == 'craftbukkit'

    url = "#{api_url}/plugins/#{server}/#{name}/#{version}"
    info = JSON.parse(open(url).read)

    data[:version] = info['versions'][0]['version']
    data[:download] = "#{api_url}/plugins/#{server}/#{name}/#{version}/download"
    data
  end
end
