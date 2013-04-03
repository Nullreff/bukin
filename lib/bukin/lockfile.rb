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

  def set_server(name, version, file)
    self.server = {
      'name' => name,
      'version' => version,
      'file' => file
    }
  end

  def add_plugin(name, version, *files)
    self.plugins[name] = {
      'version' => version,
      'files' => files
    }
    save
  end

  def add(type, *args)
    case type
    when :server
      set_server(*args)
    when :plugin
      add_plugin(*args)
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
