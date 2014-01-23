Bukin
=====

Plugin and server installer for Minecraft similar to [Bundler](http://gembundler.com/).

[![Build Status](https://travis-ci.org/Nullreff/bukin.png)](https://travis-ci.org/Nullreff/bukin)
[![Dependency Status](https://gemnasium.com/Nullreff/bukin.png)](https://gemnasium.com/Nullreff/bukin)
[![Code Climate](https://codeclimate.com/github/Nullreff/bukin.png)](https://codeclimate.com/github/Nullreff/bukin)
[![Coverage Status](https://coveralls.io/repos/Nullreff/bukin/badge.png?branch=master)](https://coveralls.io/r/Nullreff/bukin?branch=master)

Installation
------------

Bukin requires Ruby 1.9 or greater.

### Debian/Ubuntu

    apt-get install ruby
    gem install bukin --no-ri --no-rdoc

### CentOS/RHEL

CentOS 6.x comes with Ruby 1.8 which is incompatable with Bukin.  You'll need to [download and install](http://www.ruby-lang.org/en/downloads/) a newer version.  After that just run

    gem install bukin --no-ri --no-rdoc

Features
--------

Bukin is still a work in progress and is far from feature complete.  Currently it supports:

* Resource installation from
  * [dev.bukkit.org](http://dev.bukkit.org/)
  * [dl.bukkit.org](http://dl.bukkit.org/)
  * [Jenkins](http://jenkins-ci.org/)
  * Direct download
* Versioning
  * Specific versions
  * Categories (ex: latest test build)
  * Auto selection if none specified
* Automatic or user specified filtering of downloaded files
* Automatic or user specified extraction of zip files
* Installation groups

Eventually, I'd like to add some of the following:

* A lockfile that tracks exactly what versions are installed
* Automatic detection of already installed plugins
* Dependency tracking and resolution
* More complex version selectors
* Modpack support
* Resource installation from git
* Top level 'source' directives
* More commands for viewing information and updating plugins

If you have features you'd like to see, pull request are welcome.
    
Usage
-----

Bukin works by reading a list of dependencies from a `Bukfile`.  The most basic usage would be:

```bash
echo "server 'craftbukkit'" > Bukfile
bukin install
```

Specify a server using the `server` keyword and a plugin using the `plugin` keyword.

```ruby
server 'craftbukkit'
plugin 'worldedit'
plugin 'worldguard'
```

You can specify groups that resources should be placed in.  This allows you to only install specific plugins depending on your environment or server setup.

```ruby
# Will not be installed if the group 'test' is excluded
plugin 'worldedit', group: :test

group :test do
  plugin 'worldguard'
  plugin 'worldedit'
end

# Will not be installed if both the groups 'test' and 'development' are excluded
plugin 'worldedit', group: [:test, :development]

group :test, :development do
  plugin 'worldguard'
  plugin 'worldedit'
end

# Will be installed regardless of what groups are specified
plugin 'worldguard'
```

When installing, resources that exist only in excluded groups will not be installed.

```bash
bukin install --without development test
```

You can specify specific versions of a plugin or server to install.  Craftbukkit uses its own [special version naming](http://dl.bukkit.org/about/) (artifact slugs).

```ruby
server 'craftbukkit', 'build-2754'
plugin 'worldedit', '5.5.5'
plugin 'worldguard', '5.7.3'
```

By default, bukin will try to download jar files from bukkit dev.  If only zip files are available, it will automatically extract all jar files from it.  If you want to specify what files are extracted from a zip file, use the `extract` option.  It takes a string or [ruby regular expression](http://ruby-doc.org/core-1.9.3/Regexp.html) used to match file names in the zip file.

```ruby
plugin 'permissionsex', '1.19.5', extract: /PermissionsEx.*\.jar/
```

Plugins or servers can also be downloaded from Jenkins. Just specify the base url for Jenkins and a [ruby regular expression](http://ruby-doc.org/core-1.9.3/Regexp.html) matching the file you want to download.  If no file is specified, bukin will download the first one listed.

```ruby
server 'spigot', 'build-844', jenkins: 'http://ci.md-5.net', file: /spigot\.jar/
```

Need something custom?  Use the `download` option.  Version is optional but will display when the plugin is downloading.

```ruby
plugin 'mycustomplugin', '2.4', download: 'http://example.com/My-Custom-Plugin.jar'
```

When installing, the entire Bukfile is evaluated as ruby code.  This means that you can do just about anything with it.  For instance, if you wanted to conditionally install spigot if the file `spigot.yml` exists, you could do

```ruby
if File.exist? 'spigot.yml'
  server 'spigot', jenkins: 'http://ci.md-5.net'
else
  server 'craftbukkit'
end
```

Just make sure that you read and trust any Bukfile you download before running `bukin install`.
