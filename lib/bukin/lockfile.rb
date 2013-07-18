require 'yaml'

LOCK_FILE = 'Bukfile.lock'

class Bukin::Lockfile

  def initialize(*)
    if File.exist?(LOCK_FILE)
      @lockfile = YAML::load_file(LOCK_FILE)
    else
      @lockfile = {
        'resources' => {}
      }
    end
  end

  def add(data)
    self.resources[data[:name]] = {
      'version' => data[:version],
      'files' => data[:files] || [data[:file]]
    }
    save
  end

  def resources
    @lockfile['resources']
  end

  def save
    File.open(LOCK_FILE, "w") {|file| file.write @lockfile.to_yaml}
  end
end
