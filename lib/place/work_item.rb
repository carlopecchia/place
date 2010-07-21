
require 'set'

module Place

# Each WorkItem has a work-item id (wid) and an url that refers to its main xml file (workitem.xml) located under its own directory (that terminates with its Polarion ID = our wid).
class WorkItem < Ohm::Model
  attribute :wid
  index :wid
  
  attribute :url
  attribute :type
  index :type
  attribute :fields
  
  reference :author, User
  set :assignees, User
    
  reference :timepoint, TimePoint
  reference :project, Project
  
  set :watches, User
  collection :workrecords, WorkRecord, :workitem
  collection :comments, Comment, :workitem
  
  # Collect all workitems (wid and url) under a given project url
  def self.collect_all(base_url)
    Dir.glob(base_url + '/tracker/workitems/**/workitem.xml').each do |filename|
	  wi = WorkItem.create(
		:wid	=> File.dirname(filename).split(/\//).last,
		:url	=> filename,
		:fields => "{}"
	  )
	  project_prefix = wi.wid.split(/\-/)[0]
	  wi.project = Project.find_by_prefix(project_prefix)
	  Place.logger.info("collected workitem at #{wi.url}")
	  wi.save	  
	end
  end

  # Retrieve a specific workitem (based on wid and url only)
  def retrieve
    content = IO.readlines(url).join('')
	doc = Nokogiri::XML(content)
	  
    doc.xpath('//work-item/field').each do |field|
      self[field.attributes['id'].to_s] = field.content
    end

    self.type = self[:type]
	
	self.author = User.find_by_name(self[:author])

	unless self[:assignee].nil?
	  self[:assignee].split.each do |name|
	    u = User.find_by_name(name)
		unless u.nil?
	      self.assignees << u
		  u.assignments << self  
		end
	  end
	end

	self.timepoint = TimePoint.find_by_tid(self['timePoint'])
	
	%w(initialEstimate timeSpent remainingEstimate).each do |t|
	  self[t] = to_hours(self[t])
	end
	
	# links
    doc.xpath('/work-item/field[@id="linkedWorkItems"]/list/struct').each do |struct|
	  l = Link.create(
		:role		=> struct.xpath('item[@id="role"]').text,
		:suspect	=> struct.xpath('item[@id="suspect"]').text == 'true' ? true : false,
		:revision	=> struct.xpath('item[@id="revision"]').empty? ? false : true,
		:from		=> self,
		:to			=> WorkItem.find_by_wid(struct.xpath('item[@id="workItem"]').text),
		:from_wid	=> self.wid,
		:to_wid		=> struct.xpath('item[@id="workItem"]').text
		)
	end
	
	# comments
	Dir.glob(File.dirname(url) + '/comment-*.xml').each do |filename|
	  c = Comment.create(:url => filename)
	  c.retrieve
	end
	
	# workrecords
	Dir.glob(File.dirname(url) + '/workrecord-*.xml').each do |filename|
	  wr = WorkRecord.create(:url => filename)
	  wr.retrieve
	end
	
	Place.logger.info("retrieved workitem #{self.wid}")	
	
	self.save
  end
  
  # Get value from specified field, +nil+ if not present
  def [](fname)
    JSON.parse(fields)[fname.to_s]
  end
  
  # Set value for specified field
  def []=(fname, fvalue)
    h = JSON.parse(self.fields)
    h[fname.to_s] = fvalue
	self.fields = h.to_json
  end
  
  # Returns a workitem by its wid, +nil+ if not present
  def self.find_by_wid(wid)
    wis = self.find(:wid => wid)
	wis.nil? ? nil : wis[0]
  end
  
  # Returns all workitems of the given +type+
  def self.find_by_type(type)
    #self.all.select{|wi| wi.type == type.to_s}
	self.find(:type => type.to_s)
  end
  
  # Returns all links from the current workitems to others, eventually only with a specified role
  def links_out(role=nil)    
	if role.nil?
	  Link.find(:from_wid => self.wid)
	else
	  Link.find(:from_wid => self.wid, :role => role.to_s)
	end
  end
  
  # Returns all links to the current workitems from others, eventually only with a specified role
  def links_in(role=nil)
	if role.nil?
	  Link.find(:to_wid => self.wid)
	else
	  Link.find(:to_wid => self.wid, :role => role.to_s)
	end
  end
  
  # Returns all the fields name for the workitem
  def field_names
    JSON.parse(self.fields).keys.sort
  end
  
  # Returns the total sum, for a given +field+, from descendant and workitem itself
  # Note: descendants = children with parent role 
  def total_on(field)
    # return a past computed value if present
	return self["_total_on_#{field}"]  unless self["_total_on_#{field}"].nil?
  
    # computing the total
	total = self[field].nil? ? 0 : self[field]
	children.each{|c| total += c.total_on(field) }
	
	# saving (momoizing) for future invocations
	self["_total_on_#{field}"] = total.to_f
	self.save
	
	total.to_f
  end

  
  private

  
  # Returns workitem effective children (linked in with a parent role)
  def children
    tmp = [].to_set
	project.parent_roles.each do |role|
	  tmp.merge(links_in(role).map{|lnk| lnk.from})  unless links_in(role).empty?
	end
    tmp.to_a
  end

end

end
