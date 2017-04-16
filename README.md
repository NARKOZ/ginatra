# Ginatra

[![Build Status](https://img.shields.io/travis/NARKOZ/ginatra/master.svg)](https://travis-ci.org/NARKOZ/ginatra)
[![Code Climate](https://img.shields.io/codeclimate/github/NARKOZ/ginatra.svg)](https://codeclimate.com/github/NARKOZ/ginatra)
[![Gem Version](https://img.shields.io/gem/v/ginatra.svg)](https://rubygems.org/gems/ginatra)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/NARKOZ/ginatra/blob/master/LICENSE.txt)

**Ginatra** is a simple web-based git repository browser built on Ruby Sinatra.

[ [website](http://narkoz.github.io/ginatra) |
[screenshots](http://narkoz.github.io/ginatra/screenshots) |
[demo](http://narkoz.github.io/ginatra/demo) ]

## Features

+ Easy installation
+ Multiple repository support
+ Multiple branch/tag support
+ Commit history, diff, patch
+ Feeds in Atom format
+ Syntax highlighting
+ Repository stats
+ Smart HTTP support
+ [and more](http://narkoz.github.io/ginatra#features)

## Installation

There are 2 ways to install Ginatra: as a packaged Ruby gem or as a Sinatra app.  
It's recommended to install it as a ruby gem, unless you know what you're doing.

### Ginatra gem

Run the following command to install Ginatra from RubyGems:

```sh
gem install ginatra -v 4.1.0
```

Create config file (see [Configuration](#configuration) section in README).

Start the Ginatra server:

```sh
RACK_ENV=production ginatra run
```

By default Ginatra will run on `localhost:9797`

### Ginatra app

Run the following commands to install Ginatra from source:

```sh
git clone git://github.com/NARKOZ/ginatra.git
cd ginatra/
git checkout v4.1.0
bundle
```

Create config file or modify existing (see [Configuration](#configuration) section in README).

Start the Ginatra server:

```sh
export RACK_ENV=production 
./bin/ginatra run
```

By default Ginatra will run on `localhost:9797`

## Configuration

Create `~/.ginatra/config.yml` file with your own settings. See
[`config.yml`](https://github.com/NARKOZ/ginatra/blob/master/config.yml) for a reference.

`git_dirs` - Ginatra will look into these folders for git repositories. It's
required to append `*` at the end of path. Example: `/home/Development/repos/*`

`sitename` - name of the site. Used in the page title and header.

`description` - description of web interface. Used in index page.

`port` - port that Ginatra server will run at.

`host` - host that Ginatra server will run at.

`prefix` - prefix for the host serving Ginatra. Used when Ginatra is installed
in subdirectory.

`git_clone_enabled?` - enables smart HTTP support and allows to clone git
repositories.

`log_file` - location of the log file where Ginatra will log warnings and
errors. If this setting doesn't present Ginatra will log out to the standard
output (stdout).

If you installed Ginatra as an app, you can change settings by editing
`config.yml` file in root folder.

You need to restart web server after applying changes to config file.

## CLI

You can interact with Ginatra via CLI. The following commands are available:

```sh
ginatra run    # Starts Ginatra server
ginatra stop   # Stops Ginatra server
ginatra status # Checks status of the Ginatra server (running or not)
ginatra -v     # Shows version of Ginatra
ginatra -h     # Lists available commands and their options
```

## How to Contribute

Open issues are labeled per perceived difficulty. See [contributing
guidelines](https://github.com/NARKOZ/ginatra/blob/master/CONTRIBUTING.md).
