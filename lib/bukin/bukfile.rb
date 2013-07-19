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
    add_resource(name, :server, args)
  end

  def plugin(name, *args)
    add_resource(name, :plugin, args)
  end

private
  def add_resource(name, type, args)
    if @resources.find { |resource| resource[:name] == name && resource[:type] == type }
      raise Bukin::BukinError, "Error: The #{type} '#{name}' is declared more than once in your #{FILE_NAME}"
    end

    options = args.last.is_a?(Hash) ? args.pop : {}
    version = args.pop || nil

    resource = { :name => name, :type => type, :version => version }.merge(options)

    @resources << resource
  end
end
