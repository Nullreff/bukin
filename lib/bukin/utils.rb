require 'bukin/version'
require 'open-uri'

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

def install_plugin(name, version, server)
  return false if @lockfile.plugins.has_key?(name)

  download_version = @bukget.resolve_version(name, version, server)
  data, file_name = @bukget.download(name, download_version, server)
  save_download(data, file_name, PLUGINS_PATH)
  @lockfile.add_plugin(name, download_version, file_name)
  return file_name, download_version
end

def pretty_version(version)
  case version
  when 'latest'
    "the latest version"
  when 'latest-rb'
    "the latest recommended build"
  when 'latest-beta'
    "the latest beta build"
  when 'latest-dev'
    "the latest development build"
  when /^git-(.*)$/
    "git commit #{$1}"
  when /^build-(.*)$/
    "build \##{$1}"
  else
    "version #{version}"
  end
end
