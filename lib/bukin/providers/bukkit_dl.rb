require 'bukin/utils'
require 'json'

# Bukkit download api
# Docs: http://dl.bukkit.org/about/
class Bukin::BukkitDl
  attr_reader :url

  def initialize(url = 'http://dl.bukkit.org')
    @url = url
  end

  def api_url
    "#{url}/api/1.0/downloads"
  end

  def download_url
    url
  end

  def download(name, version)
    url = download_url + info(name, version)['file']['url']
    download_file(url)
  end

  def info(name, version)
    url = "#{api_url}/projects/#{name}/view/#{version}/"
    JSON.parse(open(url).read)
  end
end
