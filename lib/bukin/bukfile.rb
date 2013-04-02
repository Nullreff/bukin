
class Bukin::Bukfile
    NAME = 'Bukfile'

    attr_accessor :server_info, :plugins_info

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
