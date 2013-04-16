class Bukin::Bukfile
  FILE_NAME = 'Bukfile'

  attr_accessor :server_info, :plugins_info

  def self.from_file(path = nil)
    path ||= File.join(Dir.pwd, FILE_NAME)
    from_code(File.read(path))
  end

  def self.from_block(&block)
    from_code(&block)
  end

  def self.from_code(code)
    bukfile = Bukin::Bukfile.new
    bukfile.instance_eval(code)
    bukfile
  end

  def initialize
    @plugins_info = []
  end

  def server(name, version = 'latest-rb')
    unless @server_info
      @server_info = { name: name, version: version }
    else
      abort("Error: There is more than one server declared in your #{INSTALL_FILE}")
    end
  end

  def plugin(name, version = 'latest')
    @plugins_info << { name: name, version: version }
  end
end
