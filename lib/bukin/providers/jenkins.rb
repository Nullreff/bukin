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

    unless /^build-(.*)$/.match(version)
      raise Bukin::InstallError, "The plugin #{name} (#{version}) has an improper version format for downloading from Jenkins.  It should be in the form of 'build-<number>'"
    end

    base_path = "#{data[:jenkins]}/job/#{name}/#{$1}"
    url = "#{base_path}/api/json"
    info = JSON.parse(open(url).read)

    download_info = find_file(info['artifacts'], data[:file])
    data[:version] = version
    data[:download] = "#{base_path}/artifact/#{download_info['relativePath']}"
    data
  end

  def find_file(artifacts, file_name)
    artifacts.find do |artifact|
      if file_name.is_a?(Regexp)
        file_name =~ artifact['fileName']
      elsif file_name.is_a?(String)
        file_name == artifact['fileName']
      else
        true
      end
    end
  end
end
