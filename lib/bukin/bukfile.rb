class Bukin::Bukfile
  FILE_NAME = 'Bukfile'

  attr_accessor :resources

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
    @resources = []
  end

  def server(name, args)
    add_resource(name, '.', args)
  end

  def plugin(name, args)
    add_resource(name, 'plugins', args)
  end

private
  def add_resource(name, default_path, *args)
    if @resources.find { |resource| resource[:name] == name }
      abort("Error: #{name} is declared more than once in your #{FILE_NAME}")
    end

    options = args.last.is_a?(Hash) ? args.pop : {}
    version = args.pop || nil

    resource = { :name => name, :version => version }.merge(options)
    resource[:path] ||= default_path

    @resources << resource
  end
end
