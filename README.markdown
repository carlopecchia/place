Place is a Ruby library aimed to gather and manage objects from [Polarion ALM](http://www.polarion.com/)&trade; repositories. Its name comes from the contraction of "**P**olarion **lace**".


# Intro

**Place** collects informations from *Polarion ALM &trade;* and turns it into easy manageable ruby objects, which are managed by excellent key-value store [Redis](http://code.google.com/p/redis/), via the Ruby library [Ohm](http://ohm.keyvalue.org/).

*Polarion &trade;* is an "Application Lifecycle Management" tool produced by *Polarion Software GmbH*. For more info on *Polarion ALM &trade;* please refers to <http://www.polarion.com/>.

# Why?

Basically I'd like to easy access to items inside a Polarion projects (namely "workitems"), as well as see relations among multiprojects workitems. That saved me a lot of time in extracting information and producing reports.


# Examples

See the [Examples wiki page](http://wiki.github.com/carlopecchia/place/examples), please.


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
