require 'bukin/lockfile'
require 'zip/zip'

class Bukin::Installer

  def initialize(path, use_lockfile = false)
    if use_lockfile
      @lockfile = Bukin::Lockfile.new
    end
    @paths = { :server => '.', :plugin => 'plugins' }
  end

  def install(data)
    path = @paths[data[:type]]

    file_data, file_name = download_file(data[:download])
    if File.extname(file_name) == '.zip'
      match = data[:extract] || /\.jar$/
      file_names = extract_files(file_data, path, match)
      if file_names.empty?
        raise(Bukin::InstallError, "The resource #{data[:name]} (#{data[:version]}) has no jar files in it's download (zip file).")
      end
      if @lockfile
        if file_names.size == 1
          data[:file] = file_names.first
        else
          data[:files] = file_names
        end
        @lockfile.add(data)
      end
    else
      save_download(file_data, file_name, path)
      if @lockfile
        data[:file] = file_name
        @lockfile.add(data)
      end
    end
  end

  def extract_files(file_data, path, match)
    file_names = []
    tempfile = Tempfile.new('bukin')
    begin
      tempfile.write(file_data)
      tempfile.close

      Zip::ZipFile.open(tempfile.path) do |zipfile|
        jars = zipfile.find_all {|file| file.name =~ match}
        jars.each do |file|
          file.extract(path + '/' + file.name) { true }
          file_names << file.name
        end
      end
    ensure
      tempfile.close
      tempfile.unlink
    end
    file_names
  end
end
