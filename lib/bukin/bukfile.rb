module Bukin
  class Bukfile
    FILE_NAME = 'Bukfile'
    attr_reader :path, :resources

    def initialize(path = nil, &block)
      @resources = []
      @path = path || File.join(Dir.pwd, FILE_NAME)
      @groups = []

      if block
       instance_eval(&block)
      else
        instance_eval(File.read(@path))
      end
    end

    def server(name, *args)
      add_resource name, :server, args
    end

    def plugin(name, *args)
      add_resource name, :plugin, args
    end

    def group(*groups)
      raise BukfileError.nested_groups unless @groups.empty?
      groups.each do |group|
        raise BukfileError.not_symbol(group) unless group.is_a?(Symbol)
      end

      @groups = groups
      yield
      @groups = []
    end

  def to_s
    @reources.map do |resource|
      result = "#{resource[:name]}"
      result << " (#{resource[:version]})" if resource[:version]
      result
    end.join('\n')
  end

  private
    def add_resource(name, type, args)
      raise(
        BukinError,
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

      resource[:group] = build_groups(resource[:group])

      @resources << resource
    end

    def resource_exists?(name, type)
      @resources.any? do |resource|
        resource[:name] == name && resource[:type] == type
      end
    end

    def build_groups(group)
      case group
      when nil
        @groups.uniq
      when Symbol
        [group] | @groups
      when Array
        group | @groups
      else
        raise BukfileError.not_symbol(group)
      end
    end
  end
end
