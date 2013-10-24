require 'json'

module Bukin
  # Bukkit download api
  # Docs: http://dl.bukkit.org/about/
  class BukkitDl < Provider
    @name = :bukkit_dl
    @default_url = 'http://dl.bukkit.org'
    @default_version = 'latest-rb'

    def resolve_info
      url = "#{data[:bukkit_dl]}/api/1.0/downloads/projects/#{name}/view/#{version}/"
      info = JSON.parse(open(url).read)

      data[:version] = "build-#{info['build_number']}"
      data[:download] = data[:bukkit_dl] + info['file']['url']
      data
    end
  end
end
