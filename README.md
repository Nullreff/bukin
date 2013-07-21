Bukin
=====

Plugin and server installer for Minecraft similar to [Bundler](http://gembundler.com/).  Still a work in progress...

[![Build Status](https://travis-ci.org/Nullreff/bukin.png)](https://travis-ci.org/Nullreff/bukin)
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

By default, bukin will try to download jar files from bukkit dev.  If only zip files are available, it will automatically extract all jar files from it.  If you want to specify what files are extracted from a zip file, use the `extract` option.  It takes a string or [ruby regular expression](http://ruby-doc.org/core-1.9.3/Regexp.html) used to match file names in the zip file.

    plugin 'permissionsex', '1.19.5', :extract => /PermissionsEx.*\.jar/

Plugins or servers can also be downloaded from Jenkins. Just specify the base url for Jenkins and a [ruby regular expression](http://ruby-doc.org/core-1.9.3/Regexp.html) matching the file you want to download.  If no file is specified, bukin will download the first one listed.

    server 'spigot', 'build-844', :jenkins => 'http://ci.md-5.net', :file => /spigot\.jar/

Need something custom?  Use the `download` option.  Version is optional but will display when the plugin is downloading.

    plugin 'mycustomplugin', '2.4', :download => 'http://example.com/My-Custom-Plugin.jar'

