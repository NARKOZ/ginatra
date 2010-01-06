Ginatra
=======

This project  is to make a  clone of gitweb in  Ruby and Sinatra. It  serves git
repositories out of a set of  specified directories using an array of glob-based
paths. I have plans to make it  function just as gitweb does, including leeching
config files and suchlike.

Updating to the Most Recent Release (Gem):
------------------------------------------

- ` $ gem install ginatra`
- (re)Move `~/.ginatra`
- Run the following to open an irb with Ginatra loaded: ` $ irb -r 'rubygems' -r 'rubygems'`
- In this irb session, run the following then close it: `>> Ginatra::Config.setup!`

**BEWARE**: The last method that you just called will dump a config to `~/.ginatra/config.yml`.
This ignores anything already there, so be careful. You have been warned.

You can now copy the contents your old `~/.ginatra/` file into `~/.ginatra/config.yml`.

Installation
------------

You should be using Git 1.6.3 or later just to be sure that it all works:

    $ git --version
    git version 1.6.3

Next, just do the following (your setup may require sudo):

    $ gem install ginatra

This pulls down most of the required dependencies too.

The last dependency you need is pygments, an awesome python syntax highlighter. 
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

**Patches**

- James Tucker (raggi)
- Elia Schito (elia)
- Scott Wisely (Syd)
- Jonathan Stott (namelessjon)

**Thanks**

Too many to name. Thanks be to you all.

Screenshots
-----------

**Index**

![Ginatra Index](http://lenary-uploads.appspot.com/img/i?id=ag5sZW5hcnktdXBsb2Fkc3IMCxIFSW1hZ2UYox8M&w=500&h=500 "Ginatra Index")

**Log**

![Ginatra Log](http://lenary-uploads.appspot.com/img/i?id=ag5sZW5hcnktdXBsb2Fkc3IMCxIFSW1hZ2UYvRcM&w=500&h=500 "Ginatra Log")

**Commit**

![Ginatra Commit](http://lenary-uploads.appspot.com/img/i?id=ag5sZW5hcnktdXBsb2Fkc3IMCxIFSW1hZ2UYvBcM&w=500&h=500 "Ginatra Commit")

**Tree**

![Ginatra Tree](http://lenary-uploads.appspot.com/img/i?id=ag5sZW5hcnktdXBsb2Fkc3IMCxIFSW1hZ2UYpB8M&w=500&h=500 "Ginatra Tree")

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
