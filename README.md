Bukin
=====

Plugin and server installer for Minecraft similar to [Bundler](http://gembundler.com/).  Still a work in progress...

[![Dependency Status](https://gemnasium.com/Nullreff/bukin.png)](https://gemnasium.com/Nullreff/bukin)
[![Code Climate](https://codeclimate.com/github/Nullreff/bukin.png)](https://codeclimate.com/github/Nullreff/bukin)

Installation
------------

Install [rubygems](http://docs.rubygems.org/read/chapter/3) then:

    gem install bukin


Usage
-----

Bukin works by reading a list of dependencies from a `Bukfile`.  The most basic usage would be:

    echo "server 'craftbukkit'" > Bukfile
    bukin install

Currently only [Craftbukkit](http://bukkit.org/) is available as a server and [BukkitDev](http://dev.bukkit.org/) is the only plugin api supported.  Specify a server using the `server` keyword and a plugin using the `plugin` keyword.

    server 'craftbukkit'
    plugin 'worldedit'
    plugin 'worldguard'

You can specify specific versions of a plugin or server to install.  Craftbukkit uses its own [special version naming](http://dl.bukkit.org/about/) (artifact slugs).

    server 'craftbukkit', 'build-2754'
    plugin 'worldedit', '5.5.5'
    plugin 'worldguard', '5.7.3'

Need something custom?  Use the `download` option.  Version is optional but will display when the plugin is downloading.

    server 'craftbukkit', 'spigot-735', download: 'http://ci.md-5.net/job/Spigot/735/artifact/Spigot-Server/target/spigot.jar'
    plugin 'mycustomplugin', '2.4', download: 'http://example.com/My-Custom-Plugin.jar'

