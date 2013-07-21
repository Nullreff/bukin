require 'json'

# Api for downloading from jenkins
class Bukin::Jenkins
  attr_reader :data

  def initialize(data)
    @data = data
  end

  def resolve_info
    name = data[:name]
    version = data[:version] || 'lastSuccessfulBuild'

    if version =~ /^build-(.*)$/
      base_path = "#{data[:jenkins]}/job/#{name}/#{$1}"
      url = "#{base_path}/api/json"
      info = JSON.parse(open(url).read)

      download_info = if data[:file]
                        info['artifacts'].find do |artifact| 
                          artifact['fileName'] =~ data[:file]
                        end
                      else
                        info['artifacts'].first
                      end

      data[:version] = data[:display_version] = version
      data[:download] = "#{base_path}/artifact/#{download_info['relativePath']}"
    else
      raise Bukin::InstallError, "The plugin #{name} (#{version}) has an improper version format for downloading from Jenkins.  It should be in the form of 'build-<number>'"
    end
    data
  end
end
