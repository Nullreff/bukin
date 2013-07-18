class Bukin::Bukfile
  FILE_NAME = 'Bukfile'

  attr_accessor :resources

  def initialize(path = nil, &block)
    @resources = []
    path ||= File.join(Dir.pwd, FILE_NAME)
    if block
     instance_eval(&block)
    else
      instance_eval(File.read(path))
    end
  end

  def server(name, *args)
    add_resource(name, '.', args)
  end

  def plugin(name, *args)
    add_resource(name, 'plugins', args)
  end

private
  def add_resource(name, default_path, args)
    if @resources.find { |resource| resource[:name] == name }
      raise Bukin::BukinError, "Error: #{name} is declared more than once in your #{FILE_NAME}"
    end

    options = args.last.is_a?(Hash) ? args.pop : {}
    version = args.pop || nil

    resource = { :name => name, :version => version }.merge(options)
    resource[:path] ||= default_path

    @resources << resource
  end
end
