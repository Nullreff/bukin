require 'bukin/lockfile'
require 'zip/zip'

class Bukin::Installer

  def initialize(path, use_lockfile = false)
    if use_lockfile
      @lockfile = Bukin::Lockfile.new
    end
    @paths = { server: path, plugin: "#{path}/plugins" }
  end

  def install(type, data)
    unless @paths.keys.include?(type)
      raise(ArgumentError, "You must specify one of the following types to install: #{@paths.keys.to_s}")
    end

    file_data, file_name = download_file(data[:download])
    if File.extname(file_name) == '.zip'
      match = data[:extract] || /\.jar$/
      file_names = extract_files(file_data, @paths[type], match)
      if file_names.empty?
        raise(Bukin::InstallError, "The plugin #{data[:name]} (#{data[:version]}) has no jar files in it's download (zip file).")
      end
      if @lockfile
        if file_names.size == 1
          data[:file] = file_names.first
        else
          data[:files] = file_names
        end
        @lockfile.add(type, data)
      end
    else
      save_download(file_data, file_name, @paths[type])
      if @lockfile
        data[:file] = file_name
        @lockfile.add(type, data)
      end
    end
  end

  def extract_files(file_data, path, match)
    file_names = []
    file = Tempfile.new('bukin')
    begin
      file.write(file_data)
      file.close

      Zip::ZipFile.open(file.path) do |zipfile|
        jars = zipfile.find_all {|file| file.name =~ match}
        jars.each do |file|
          file.extract(path + '/' + file.name) { true }
          file_names << file.name
        end
      end
    ensure
      file.close
      file.unlink
    end
    file_names
  end
end
