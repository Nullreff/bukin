require 'bukin/utils'
require 'json'

# Bukkit download api
# Docs: http://dl.bukkit.org/about/
class Bukin::BukkitDl
  attr_reader :api_url, :download_url

  def initialize(url = 'http://dl.bukkit.org')
    @api_url = "#{url}/api/1.0/downloads"
    @download_url = url
  end

  def download(name, version)
    url = @download_url + info(name, version)['file']['url']
    download_file(url)
  end

  def info(name, version)
    url = "#{@api_url}/projects/#{name}/view/#{version}/"
    JSON.parse(open(url).read)
  end

  def resolve_build(name, version)
    "build-#{info(name, version)['build_number']}"
  end

  def resolve_version(name, version)
    info(name, version)['version']
  end
end
