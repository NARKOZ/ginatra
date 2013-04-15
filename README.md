# Ginatra

[![Build Status](https://travis-ci.org/NARKOZ/ginatra.png?branch=master)](https://travis-ci.org/NARKOZ/ginatra)
[![Gem Version](https://fury-badge.herokuapp.com/rb/ginatra.png)](http://badge.fury.io/rb/ginatra)

**Ginatra** is a Git web interface. It allows browsing a git repository (or a set of
git repositories) using a web browser.

Features include:

+ Multiple repository support
+ Multiple branch/tag support
+ Commit history, diff, patch
+ Feeds in Atom format
+ Syntax highlighting
+ Branch graphs

## Requirements

+ Ruby 1.9.2 or newer
+ Git 1.6.3 or newer

## Installation

***Recommended*** Use edge version (stable as in beta):

```sh
git clone git://github.com/NARKOZ/ginatra.git
cd ginatra/
bundle
# add some git repositories to browse (put them into `repos` directory)
#   and start Ginatra web server:
./bin/ginatra server
```

By default Ginatra will run on `localhost:9797`

--

Ginatra is also available as a gem in [Rubygems](https://rubygems.org/gems/ginatra).
You can install old release via `gem install ginatra`.

## Configuration

You can change settings by editing `config.yml` file in root folder.  
Alternatively you can create `~/.ginatra/config.yml` file with your own
settings, use
[`config.yml`](https://github.com/NARKOZ/ginatra/blob/master/config.yml) as a reference.

You need to restart web server after applying changes to config file.
