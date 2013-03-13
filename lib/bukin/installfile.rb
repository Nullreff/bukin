INSTALL_FILE = 'Bukfile'

class Bukin::Installfile

    attr_accessor :server, :plugins

    def initialize
        @plugins = {}
    end

    def server(name, version = 'latest-rb')
        unless @server
            @server = { 'name' => name, 'version' => version }
        else
            abort("Error: There is more than one server declared in your #{INSTALL_FILE}")
        end
    end

    def plugin(name, version = 'latest')
        unless @plugins[name]
            @plugins[name] = { 'version' => version }
        else
            abort("Error: The plugin #{name} is listed more than once in your #{INSTALL_FILE}")
        end
    end
end
