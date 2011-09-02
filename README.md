# Ginatra
[![](http://stillmaintained.com/lenary/ginatra.png)](http://stillmaintained.com/lenary/ginatra)

[![](http://travis-ci.org/lenary/ginatra.png)](http://travis-ci.org/lenary/ginatra)


This project  is to make a  clone of gitweb in  Ruby and Sinatra. It  serves git
repositories out of a set of  specified directories using an array of glob-based
paths. I have plans to make it  function just as gitweb does, including leeching
config files and suchlike.

Installation
------------

**NEW: You should be using Ruby 1.9.2: because it's awesome!**

To install ginatra:

    $ gem install ginatra
    ...
    $ ginatra setup
    checked deps
    installed config

If you get those two lines of output, you're sorted. anything else and something
has gone wrong.

### External Dependencies

You should be using Git 1.6.3 or later just to be sure that it all works:

    $ git --version
    git version 1.6.3

The other dependency you need is pygments, an awesome python syntax highlighter.
To check whether you have it, run:

    $ which pygmentize

If this returns a path pointing to a 'pygmentize' binary, then you're all set.
If not you'll need to install pygments. Look at the last section of the
[jekyll wiki "install" page](http://wiki.github.com/mojombo/jekyll/install)
to see how to install it. Also make sure again that the `pygmentize` binary
is on your path.

If you want to play around with the code, you can clone the repository. This also allows you
to use a special rackup file to mount it where you wish. I am yet to sort out some of the
details of running Ginatra from a gem with a rackup.ru file.

Usage
-----

If you're just using it in development, use the following to start, check and stop Ginatra
respectively:

    $ ginatra server start
    $ ginatra server status
    $ ginatra server stop

Ginatra  also runs  on thin, with the approach outlined above.

**BEWARE:** There are issues running Ginatra on Passenger. We discourage Ginatra's use
on Passenger until we can make it stable.

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


Attribution
-----------

**Authors:**

- Samuel Elliott (lenary)
- Ryan Bigg (radar)
- Jan Topiński (simcha)

**Patches**

- James Tucker (raggi)
- Elia Schito (elia)
- Scott Wisely (Syd)
- Jonathan Stott (namelessjon)
- Michael James (umjames)

In a new spirit of openness, all those who submit a patch that gets applied will gain commit access to the main (lenary/ginatra) repository.

Screenshots
-----------

**Index**

![Ginatra Index](http://cloud.github.com/downloads/lenary/ginatra/o%20\(5\).png "Ginatra Index")

**Log**

![Ginatra Log](http://cloud.github.com/downloads/lenary/ginatra/o%20\(3\).png "Ginatra Log")

**Commit**

![Ginatra Commit](http://cloud.github.com/downloads/lenary/ginatra/o%20\(4\).png "Ginatra Commit")

**Tree**

![Ginatra Tree](http://cloud.github.com/downloads/lenary/ginatra/o%20\(2\).png "Ginatra Tree")

**Branch graph**

![Branch graph](http://cloud.github.com/downloads/simcha/ginatra/branch-graph.png "Branch Graph")


Licence
-------

The MIT License

Copyright (c) 2009 Samuel Elliott

Permission is hereby granted, free of charge,  to any person obtaining a copy of
this software  and associated documentation  files (the "Software"), to  deal in
the Software  without restriction,  including without  limitation the  rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to  whom the Software is furnished to do so,
subject to the following conditions:

The above copyright  notice and this permission notice shall  be included in all
copies or substantial portions of the Software.

THE  SOFTWARE IS  PROVIDED "AS  IS", WITHOUT  WARRANTY OF  ANY KIND,  EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR  PURPOSE AND NONINFRINGEMENT. IN NO EVENT  SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE  LIABLE FOR ANY CLAIM, DAMAGES OR  OTHER LIABILITY, WHETHER
IN  AN ACTION  OF  CONTRACT, TORT  OR  OTHERWISE,  ARISING FROM,  OUT  OF OR  IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
