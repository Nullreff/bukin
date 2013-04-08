require 'socket'

module Bukin
  def self.with_friendly_errors
    yield
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
