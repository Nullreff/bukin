require 'bukin/lockfile'
require 'zip/zip'

class Bukin::Installer
  PATHS = { :server => '.', :plugin => 'plugins' }

  def initialize(path, use_lockfile = false)
    @lockfile = Bukin::Lockfile.new if use_lockfile
  end

  def install(data)
    path = PATHS[data[:type]]
    file_names = []
    dl_data, dl_name = download_file(data[:download])

    if File.extname(dl_name) == '.zip'
      match = data[:extract] || /\.jar$/
      file_names = extract_files(dl_data, path, match)
      raise Bukin::InstallError, "The resource #{data[:name]} (#{data[:version]}) has no jar files in it's download (zip file)." if file_names.empty?
    else
      save_download(dl_data, dl_name, path)
      file_names << dl_name
    end

    if @lockfile
      data[:files] = file_names
      @lockfile.add(data)
    end
  end

  def extract_files(file_data, path, match)
    file_names = []
    tempfile = Tempfile.new('bukin')
    begin
      tempfile.write(file_data)
      tempfile.close

      Zip::ZipFile.open(tempfile.path) do |zipfile|
        files = zipfile.find_all {|file| file.name =~ match}
        files.each do |file|
          file.extract(File.join(path, file.name)) { true }
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
