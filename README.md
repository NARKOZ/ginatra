# Ginatra

[![Build Status](https://img.shields.io/travis/NARKOZ/ginatra/master.svg?style=flat)](https://travis-ci.org/NARKOZ/ginatra)
[![Code Climate](https://img.shields.io/codeclimate/github/NARKOZ/ginatra.svg?style=flat)](https://codeclimate.com/github/NARKOZ/ginatra)
[![Gem Version](https://img.shields.io/gem/v/ginatra.svg?style=flat)](https://rubygems.org/gems/ginatra)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/NARKOZ/ginatra/blob/master/LICENSE.txt)

**Ginatra** is a Git web interface. It allows browsing a git repository (or a set of
git repositories) using a web browser.

## Features

+ Hassle free installation
+ Multiple repository support
+ Multiple branch/tag support
+ Commit history, diff, patch
+ Feeds in Atom format
+ Syntax highlighting
+ Repository stats
+ Smart HTTP support

## Installation

There are 2 ways to install Ginatra: as a packaged Ruby gem or as a Sinatra app.  
It's recommended to install it as a ruby gem, unless you know what you're doing.

### Ginatra gem

Run the following command to install Ginatra from RubyGems:

```sh
gem install ginatra -v 4.0.0
```

Start the Ginatra server after installation:

```sh
ginatra run
```

By default Ginatra will run on `localhost:9797`

### Ginatra app

Run the following commands to install Ginatra from source:

```sh
git clone git://github.com/NARKOZ/ginatra.git
cd ginatra/
bundle
```

Start the Ginatra server after installation:

```sh
./bin/ginatra run
```

By default Ginatra will run on `localhost:9797`

## Configuration

You can change settings by editing `config.yml` file in root folder.
Alternatively you can create `~/.ginatra/config.yml` file with your own
settings, use
[`config.yml`](https://github.com/NARKOZ/ginatra/blob/master/config.yml) as a reference.

You need to restart web server after applying changes to config file.

## Contributing

**Ways _you_ can contribute:**

* by installing and testing the software
* by using the issue tracker for...
  * reporting bugs
  * suggesting new features
* by improving the code through:
  * writing or editing documentation
  * writing test specifications
  * refactoring the code (**no patch is too small**: fix typos, add comments,
  clean up inconsistent whitespace).
  * reviewing open Pull Requests

Check out [CONTRIBUTING.md](https://github.com/NARKOZ/ginatra/blob/master/CONTRIBUTING.md)
for more information.
