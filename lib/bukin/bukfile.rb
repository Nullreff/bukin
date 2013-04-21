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

  def server(name, *args)
    if @server_info
      abort("Error: There is more than one server declared in your #{FILE_NAME}")
    end

    options = args.last.is_a?(Hash) ? args.pop : {}
    version = args.pop || nil

    @server_info = { name: name, version: version }.merge(options)
  end

  def plugin(name, *args)
    if @plugins_info.find { |p| p[:name] == name }
      abort("Error: You declared the plugin #{name} more than once in your #{FILE_NAME}")
    end

    options = args.last.is_a?(Hash) ? args.pop : {}
    version = args.pop || nil

    @plugins_info << { name: name, version: version }.merge(options)
  end
end
