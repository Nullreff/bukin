require 'thor'

class Bukin::CLI < Thor

    def initialize(*)
        super
    end

    def help(*)
        shell.say "Bukin is a plugin and server package manager for Minecraft."
        shell.say
        super
    end
end
