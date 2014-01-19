module Bukin
  class Bukfile
    FILE_NAME = 'Bukfile'
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
      add_resource name, :server, args
    end

    def plugin(name, *args)
      add_resource name, :plugin, args
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

      @resources << resource
    end

    def resource_exists?(name, type)
      @resources.any? do |resource|
        resource[:name] == name && resource[:type] == type
      end
    end
  end
end
