# Place


## Intro

**Place** stands for "**P**olarion **Lace**": a ruby library that collects informations from *Polarion &trade;* and turns it into easy manageable ruby objects.

Those objects are managed by excellent key-value store [Redis](http://code.google.com/p/redis/), via the Ruby library [Ohm](http://ohm.keyvalue.org/).

*Polarion &trade;* is an "Application Lifecycle Management" tool produced by *Polarion Software GmbH*. For more info on *Polarion ALM &trade;* please refers to <http://www.polarion.com/>.


## Usage

First we need a local working copy of the repository. Notice we need only `.polarion` directories, not the WHOLE repository:

	# obtain a local working copy of you Polarion repository
	$ svn co http://your.polarion.server/repo/.polarion local_repo/.polarion
	$ svn co http://your.polarion.server/repo/ProjectA/.polarion local_repo/ProjectA/.polarion
	$ svn co http://your.polarion.server/repo/ProjectB/.polarion local_repo/ProjectB/.polarion
	
Then we go Ruby:
	
	require 'rubygems'
	require 'place'

	include Place

	# this path refers to (root) repository local working copy
	Place.setup('./local_repo')

	Place.logger_setup('/dev/null')

	# that is not necessary each time!
	Place.gather!

	puts "Retrieved #{Project.all.size} projects."
	puts "Retrieved #{WorkItem.all.size} workitems."

	tasks = WorkItem.find_by_type :task
	puts "  tasks: #{tasks.size}"

	puts "-" * 60

	# for each task print: ID, title and list of linked in workitems
	tasks.each do |t|
	  printf("[%4s] - %-10s (%s)\n", t.wid, t[:title], t.links_in.map{|l| l.from.wid}.join(', '))
	end

	puts "-" * 60

	# do the same, but only in a project context
	p = Project.find_by_name('P')
	p.workitems(:type => :taks).each do |t|
	  printf("[%4s] - %-10s (%s)\n", t.wid, t[:title], t.links_in.map{|l| l.from.wid}.join(', '))
	end
	

## Limitations

* **Place** does *not* work with LiveDocument workitems, that are workitems stored in Microsoft document rather than .xml files.
* The actual version was tested under *Linux* and *Mac OS X* only.


## To Do

* Write more examples
* Add hyperlinks for workitems (and votes, approvals, ...)
* Implement write back into repository (=local working copy)

	
## Author

Place is written by [Carlo Pecchia](mailto:info@carlopecchia.eu) and released under the terms of Apache License (see LICENSE file).
