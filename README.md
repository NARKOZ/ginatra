# Ginatra

[![Build Status](https://img.shields.io/travis/NARKOZ/ginatra/master.svg?style=flat)](https://travis-ci.org/NARKOZ/ginatra)
[![Code Climate](https://img.shields.io/codeclimate/github/NARKOZ/ginatra.svg?style=flat)](https://codeclimate.com/github/NARKOZ/ginatra)
[![Gem Version](https://img.shields.io/gem/v/ginatra.svg?style=flat)](https://rubygems.org/gems/ginatra)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/NARKOZ/ginatra/blob/master/LICENSE.txt)

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
