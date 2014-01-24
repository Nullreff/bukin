require 'bukin/lockfile'
require 'bukin/state'
require 'zip'

module Bukin
  class Installer
    PATHS = { :server => '.', :plugin => 'plugins' }

    def initialize(path, use_lockfile = false)
      @lockfile = Lockfile.new if use_lockfile
      @state = State.new(path)
    end

    def install(resource)
      path = PATHS[resource.type]
      files = []
      dl_data, dl_name = download_file(resource.download)

      if File.extname(dl_name) == '.zip'
        match = self.get_match(resource[:extract])
        files = extract_files(dl_data, path, match)
        raise InstallError, "The resource #{resource.name} (#{resources.version}) has no jar files in it's download (zip file)." if files.empty?
      else
        files = save_download(dl_data, dl_name, path)
      end

      @state.files[resource.name, resource.version] = files
      @state.save
    end

    def extract_files(file_data, path, match)
      file_names = []
      tempfile = Tempfile.new('bukin')
      begin
        tempfile.write(file_data)
        tempfile.close

        Zip::File.open(tempfile.path) do |zipfile|
          files = zipfile.find_all {|file| file.name =~ match}
          files.each do |file|
            full_path = File.join(path, file.name)
            file.extract(full_path) { true }
            file_names << full_path
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
      full_path = File.join(path, name)
      open(full_path, 'wb') do |file|
        file.print data
      end
      [full_path]
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
        raise InstallError, "The extract option #{match} is not valid.  Please use a String, Regexp or :all"
      end
    end

  end
end
