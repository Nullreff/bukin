require 'bukin/lockfile'

class Bukin::Installer

  def initialize(path, use_lockfile = false)
    if use_lockfile
      @lockfile = Bukin::Lockfile.new
    end
    @paths = { server: path, plugin: "#{path}/plugins" }
  end

  def install(type, provider, data)
    unless @paths.keys.include?(type)
      raise(ArgumentError, "You must specify one of the following types to install: #{@paths.keys.to_s}")
    end
    file_data, file_name = download_file(data[:download])
    save_download(file_data, file_name, @paths[type])
    if @lockfile
      data[:file] = file_name
      @lockfile.add(type, data)
    end
  end
end
