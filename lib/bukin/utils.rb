require 'open-uri'

def save_download(data, name, path)
    FileUtils.mkdir_p(path)
    open("#{path}/#{name}", "wb") do |file|
        file.print data
    end
end

def download_file(url, content_disposition = false)
    open(url) do |download|
        file_name = if content_disposition
                        download.meta['content-disposition']
                                .match(/filename=(\"?)(.+)\1/)[2]
                    else
                        File.basename(url)
                    end
        data = download.read
    end
    return data, file_name
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
