class Bukin::Bukfile
  FILE_NAME = 'Bukfile'
  PROVIDERS = [:download, :jenkins, :bukkit_dl, :bukget]

  attr_reader :path, :resources

  def initialize(path = nil, &block)
    @resources = []
    @path = path || File.join(Dir.pwd, FILE_NAME)
    if block
     instance_eval(&block)
    else
      instance_eval(File.read(@path))
    end
  end

  def server(name, *args)
    add_resource name, :server, args do |resource|
      resource[:bukkit_dl] = Bukin::BukkitDl::DEFAULT_URL
    end
  end

  def plugin(name, *args)
    add_resource name, :plugin, args do |resource|
      resource[:bukget] = Bukin::Bukget::DEFAULT_URL
    end
  end

private
  def add_resource(name, type, args)
    raise(
      Bukin::BukinError,
      "Error: The #{type} '#{name}' is declared "\
      "more than once in your #{FILE_NAME}"
    ) if resource_exists?(name, type)

    options = args.last.is_a?(Hash) ? args.pop : {}
    version = args.pop || nil

    resource = {
      :name => name,
      :type => type,
      :version => version
    }.merge(options)

    # Already have a specific provider assigned?
    # If not, yield so that one can be set.
    unless PROVIDERS.any? {|key| resource.key?(key)}
      yield resource
    end

    @resources << resource
  end

  def resource_exists?(name, type)
    @resources.any? do |resource|
      resource[:name] == name && resource[:type] == type
    end
  end
end
