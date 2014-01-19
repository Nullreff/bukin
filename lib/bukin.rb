require 'bukin/version'
require 'bukin/cli'
require 'socket'

module Bukin
  class BukinError < StandardError; end
  class BukfileError < BukinError; end
  class InstallError < BukinError; end

  class VersionError < BukinError
    def initialize(name, bad_version, good_version)
      super("The resource #{name} (#{bad_version}) has an improper version. "\
            "It should be in the form of #{good_version}")
    end
  end

  class NoDownloadError < BukinError
    def initialize(name, version)
      super("The resource '#{name}' has no available downloads listed with "\
            "the version '#{version}'")
    end
  end

  class MissingProviderError < BukinError
    def initialize(resource)
      super("The #{resource[:type].to_s} '#{resource[:name]}' "\
            "is missing a provider")
    end
  end

  def self.get_json(url)
    JSON.parse(open(url).read)
  end

  def self.try_get_json(url)
    get_json(url)
  rescue OpenURI::HTTPError
    nil
  end

  def self.with_friendly_errors
    yield
  rescue Bukin::BukinError => error
    abort error.message
  rescue SocketError => error
    abort "#{error.message}\nCheck that you have a stable connection and the service is online"
  rescue Errno::ENOENT => error
    abort error.message
  rescue Interrupt
    abort ''
  rescue Exception => error
    puts %Q(
      Oops, Bukin just crashed.  Please report this at http://bit.ly/bukin-issues
      Be sure to include as much information as possible such as your Bukfile,
      Bukfile.lock and the stack trace below.
    )
    raise error
  end
end
