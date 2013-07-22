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
      match = self.get_match(data[:extract])
      file_names = extract_files(dl_data, path, match)
      raise Bukin::InstallError, "The resource #{data[:name]} (#{data[:version]}) has no jar files in it's download (zip file)." if file_names.empty?
    else
      self.save_download(dl_data, dl_name, path)
      file_names << dl_name
    end

    if @lockfile
      data[:files] = file_names.map {|file_name| File.join(path, file_name)}
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

  def save_download(data, name, path)
    FileUtils.mkdir_p(path)
    open("#{path}/#{name}", "wb") do |file|
      file.print data
    end
  end

  def download_file(url, content_disposition = false)
    open(url, "User-Agent" => "Bukin #{Bukin::VERSION}") do |download|
      file_name = if download.meta['content-disposition']
                    download.meta['content-disposition'].match(/filename=(\"?)(.+)\1/)[2]
                  else
                    File.basename(url)
                  end
      file_name = file_name.force_encoding('UTF-8') if file_name.respond_to?(:force_encoding)
      data = download.read
      return data, file_name
    end
  end

  def get_match(match)
    case match
    when Regexp
      match
    when String
      /^#{Regexp.quote(match)}$/
    when :all
      //
    when nil
      /\.jar$/
    else
      raise Bukin::InstallError, "The extract option #{match} is not valid.  Please use a String, Regexp or :all"
    end
  end

end
