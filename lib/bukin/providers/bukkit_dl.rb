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

  def resolve_info(data)
    name = data[:name]
    version = data[:version] || 'latest-rb'

    url = "#{api_url}/projects/#{name}/view/#{version}/"
    info = JSON.parse(open(url).read)

    data[:version] = "build-#{info['build_number']}"
    data[:display_version] = info['version']
    data[:download] = @url + info['file']['url']
    data
  end
end
