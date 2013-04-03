require 'bukin/lockfile'

class Bukin::Installer

  def initialize(path, use_lockfile = false)
    if use_lockfile
      @lockfile = Bukin::Lockfile.new
    end
    @paths = { server: path, plugin: "#{path}/plugins" }
  end

  def install(type, provider, *args)
    unless @paths.keys.include?(type)
      raise(ArgumentError, "You must specify one of the following types to install: #{@paths.keys.to_s}")
    end
    data, file_name = provider.download(*args)
    save_download(data, file_name, @paths[type])
    if @lockfile
      @lockfile.add(type, args[0], args[1], file_name)
    end
  end
end
