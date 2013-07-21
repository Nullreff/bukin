require 'json'

# Bukkit download api
# Docs: http://dl.bukkit.org/about/
class Bukin::BukkitDl
  DEFAULT_URL = 'http://dl.bukkit.org'
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def resolve_info
    name = data[:name]
    version = data[:version] || 'latest-rb'

    url = "#{api_url}/projects/#{name}/view/#{version}/"
    info = JSON.parse(open(url).read)

    data[:version] = "build-#{info['build_number']}"
    data[:display_version] = info['version']
    data[:download] = data[:bukkit_dl] + info['file']['url']
    data
  end

private
  def api_url
    "#{data[:bukkit_dl]}/api/1.0/downloads"
  end
end
