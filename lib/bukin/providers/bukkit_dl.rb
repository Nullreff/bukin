require 'bukin/utils'

# Base url used for bukkit downloads
BUKKIT_DL_BASE = "http://dl.bukkit.org"

# Bukkit download api
# Docs: http://dl.bukkit.org/about/
BUKKIT_DL_API = "#{BUKKIT_DL_BASE}/api/1.0/downloads"


class Bukin::BukkitDl
    attr_accessor :api_url

    def initialize(url = BUKKIT_DL_API)
        @api_url = url
    end

    def download(name, version)
        url = BUKKIT_DL_BASE + info(name, version)['file']['url']
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
