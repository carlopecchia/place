# Technical Info

## Ratio

Polarion &trade; stores data under a [Subversion](http://subversion.apache.org/) repository - located on the server it runs on - encoded in XML files at two levels:

* Global level:
  - .polarion/user-management/users/<name>/user.xml
* Project level:
  - <prj>/.polarion/tracker/timepoints/<tid>.xml
  - <prj>/.polarion/security/user-roles.xml
  - <prj>/.polarion/tracker/workitems/**/<wid>/workitem.xml
  - <prj>/.polarion/tracker/workitems/**/<wid>/workrecord-<N>.xml
  - <prj>/.polarion/tracker/workitems/**/<wid>/comment-<N>.xml

	
## Collecting & Retrieving sequence

In order to correctly build the "graph" of entities (work items, comments, work records, users, etc) we have to define a strict retrieve sequence:

	projects
	users
	for each project:
		timepoints
		workitems
			author, assignees, links, comments, workrecords
		users' roles
		users' watches

