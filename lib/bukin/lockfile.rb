require 'yaml'

LOCK_FILE = 'Bukfile.lock'

class Bukin::Lockfile

  def initialize(*)
    exists = File.exist?(LOCK_FILE)

    @lockfile = YAML::load_file(LOCK_FILE) if exists

    if @lockfile['resources'].nil? || !exists
      @lockfile = { 'resources' => {} }
    end
  end

  def add(data)
    name = data[:name]
    resources = @lockfile['resources']
    resources[name] = {
      'version' => data[:version],
      'files' => data[:files] || [data[:file]]
    }
    save
  end

  def save
    File.open(LOCK_FILE, "w") {|file| file.write @lockfile.to_yaml}
  end
end
