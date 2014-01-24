require 'yaml'
require 'fileutils'

module Bukin
  # State of the current install
  class State
    attr_reader :path, :files

    def initialize(path = nil)
      path ||= Dir.pwd
      @path = File.join(path, '.bukin')
      create_dir
      @files = FileState.new(File.join(@path, 'files.yml'), path)
    end

    def save
      create_dir
      @files.save
    end

    private
      def create_dir
        FileUtils.mkdir_p(@path) unless Dir.exist?(@path)
      end
  end

  class FileState
    def initialize(path, base_path)
      @path = path
      @base_path = base_path
      @files = (File.exist?(@path) ? YAML::load_file(@path) : {})
    end

    def [](name, version = nil)
      if version
        (@files[name] || {})[version]
      else
        @files[name]
      end
    end

    def []=(name, version = nil, value)
      if version
        (@files[name] ||= {})[version] = value
      else
        @files[name] = value
      end
    end

    def installed?(name, version)
      files = self[name, version]
      return false unless files

      files.all? do |file|
        File.exist?(File.join(@base_path, file))
      end
    end

    def delete(name)
      (self[name] || {}).each do |version, files|
        files.each do |file|
          FileUtils.rm_r(file) if File.exist?(file)
        end
      end

      @files.delete(name)
    end

    def names
      @files.keys
    end

    def save
      File.open(@path, "w") {|file| file.write @files.to_yaml}
    end
  end
end
