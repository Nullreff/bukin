require 'yaml'

LOCK_FILE = 'Bukfile.lock'

class Bukin::Lockfile

  def initialize(*)
    if File.exist?(LOCK_FILE)
      @lockfile = YAML::load_file(LOCK_FILE)
    else
      @lockfile = {
        'server' => {},
        'plugins' => {}
      }
    end
  end

  def set_server(data)
    self.server = {
      'name' => data[:name],
      'version' => data[:version],
      'file' => data[:file]
    }
  end

  def add_plugin(data)
    self.plugins[data[:name]] = {
      'version' => data[:version],
      'files' => data[:files] || [data[:file]]
    }
    save
  end

  def add(type, data)
    case type
    when :server
      set_server(data)
    when :plugin
      add_plugin(data)
    else
      raise(ArgumentError, "You must specify :server or :plugin as the type when adding to a lock file")
    end
  end

  def remove_plugin(name)
    plugins.delete(name)
    save
  end

  def plugins
    @lockfile['plugins']
  end

  def server
    @lockfile['server']
  end

  def server=(value)
    @lockfile['server'] = value
    save
  end

  def save
    File.open(LOCK_FILE, "w") {|file| file.write @lockfile.to_yaml}
  end
end
