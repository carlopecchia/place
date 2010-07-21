
Place is a Ruby library aimed to gather and manage objects from [Polarion ALM](http://www.polarion.com/)&trade; repositories. Its name comes from the contraction of "**P**olarion **lace**".


# Intro

**Place** collects informations from *Polarion ALM &trade;* and turns it into easy manageable ruby objects, which are managed by excellent key-value store [Redis](http://code.google.com/p/redis/), via the Ruby library [Ohm](http://ohm.keyvalue.org/).

*Polarion &trade;* is an "Application Lifecycle Management" tool produced by *Polarion Software GmbH*. For more info on *Polarion ALM &trade;* please refers to <http://www.polarion.com/>.

# Why?

Basically I'd like to easy access to items inside a Polarion projects (namely "workitems"), as well as see relations among multiprojects workitems. That saved me a lot of time in extracting information and producing reports.


# Examples

First we need a local working copy of the repository. Notice we need only `.polarion` directories, not the WHOLE repository:

	# obtain a local working copy of you Polarion repository
	$ svn co http://your.polarion.server/repo/.polarion local_repo/.polarion
	$ svn co http://your.polarion.server/repo/ProjectA/.polarion local_repo/ProjectA/.polarion
	$ svn co http://your.polarion.server/repo/ProjectB/.polarion local_repo/ProjectB/.polarion
	
Then we go Ruby...


## Gathering data 

    require 'place'
    include Place

    Place.setup('./local_repo')
    Place.logger_setup('/dev/null')
  
    Place.gather!
    # This reset Redis db with a fresh new copy from the
    # repository working copy (it's up to us update it).
    # Of course is needed only when working copy is updated

## Intro

    require 'place'
    include Place

    Place.setup('./local_repo')
    Place.logger_setup('/dev/null')

    puts "Users: #{User.all.size}"
    puts "Workitems: #{WorkItem.all.size}"

    all_tasks = WorkItem.find_by_type(:task)
  
    demo = Project.find_by_name('Demo')
	demo_tasks = demo.workitems(:type => :taks)
  
    t = demo_tasks.last
    puts "Assignees for #{t.wid}: #{t.assignees.map{|u| u.name}.join(' ')}"

  
## Assigned tasks

    require 'place'
    include Place

    Place.setup('./local_repo')
    Place.logger_setup('/dev/null')

    tasks = WorkItem.fnid_by_type(:task)
    assigned_tasks = tasks.reject{|wi| wi.assignees.empty? }
    assigned_tasks.each do |wi|
      puts "#{wi.wid} assigned to #{wi.assignees.map{|u| u.name}.join(' ')}"
    end


## Limitations

* **Place** does *not* work with LiveDocument workitems, that are workitems stored in Microsoft document rather than .xml files.
* The actual version was tested under *Linux* and *Mac OS X* only.

## Performance

Retrieving data from a repository working copy takes not too much time. Assuming the time required grows with the numbers of workitems, we experienced a total retrieve time of 60 seconds with 1700 workitems.

## Roadmap

* add more examples into documentation
* add hyperlinks for workitems (and votes, approvals, ...)
* (maybe) incremental update rather than one-shot gathering
* implement write back to repository
* callback for each workitem type (es: complex calculated fields)

	
## Author

Place is written by [Carlo Pecchia](mailto:info@carlopecchia.eu) and released under the terms of Apache License (see LICENSE file).
