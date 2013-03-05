# Ginatra

[![Build Status](https://travis-ci.org/NARKOZ/ginatra.png)](https://travis-ci.org/NARKOZ/ginatra)
[![Gem Version](https://fury-badge.herokuapp.com/rb/ginatra.png)](http://badge.fury.io/rb/ginatra)

**Ginatra** is a Git web interface. It allows browsing a git repository (or a set of
git repositories) using a web browser.

Features include:

+ Multiple repository support
+ Multiple branch/tag support
+ Commit history, diff
+ Feeds in ATOM format
+ Syntax highlighting
+ Branch graphs

## Requirements

+ Ruby 1.9.2 or newer
+ Git 1.6.3 or newer

## Installation

To install ginatra:

    $ gem install ginatra
    ...
    $ ginatra setup
    checked deps
    installed config

If you get those two lines of output, you're sorted. anything else and something
has gone wrong.

## Usage

If you're just using it in development, use the following to start, check and stop Ginatra
respectively:

    $ ginatra server start
    $ ginatra server status
    $ ginatra server stop

Ginatra  also runs  on thin, with the approach outlined above.

Ginatra can also start a git-daemon serving all the repositories that ginatra serves:

    $ ginatra daemon start
    $ ginatra daemon status
    $ ginatra daemon stop

This runs on the default git daemon port.

You can add a glob specified list of git repositories for ginatra to serve using the
following commands:

    $ ginatra directory add '~/Git/ginatra/*'
    $ ginatra directory list
    $ ginatra directory remove '~/Git/ginatra/*'

These should be fairly self explanatory. Help is shown with either the --help option
or by not specifying a sub-command like start, status, stop, add, list or remove.
