require 'yaml'

class Bukin::Lockfile
  FILE_NAME = 'Bukfile.lock'
  attr_reader :path

  def initialize(path = nil)
    @path = path || File.join(Dir.pwd, FILE_NAME)
    @resources = File.exist?(@path) ? YAML::load_file(@path) : {}
    @resources = { 'resources' => {} } if @resources['resources'].nil?
  end

  def add(data)
    name = data[:name]
    resources[name] = {
      'version' => data[:version],
      'files' => data[:files]
    }
    save
  end

  def resources
    @resources['resources']
  end

  def save
    File.open(@path, "w") {|file| file.write @resources.to_yaml}
  end
end
