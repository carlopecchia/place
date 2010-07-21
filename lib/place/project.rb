module Place

# Each project has a (name, url) from which (prefix, description) are derived
class Project < Ohm::Model
  attribute :name
  attribute :description
  attribute :prefix
  attribute :url

  index :name
  index :url
  index :prefix
  
  set :parent_roles
  
  collection :participations, Participation, :project
  collection :workitems, WorkItem, :project
  collection :timepoints, TimePoint, :project
  
  class << self; attr_accessor :rules end
  @rules = {
    'name'			=> '//project/field[@id="name"]',
	'description'	=> '//project/field[@id="description"]',
	'prefix'		=> '//project/field[@id="trackerPrefix"]'
  }
  
  # Collect all projects (url) under a given repository url
  def self.collect_all(base_url)
    projects_path = base_url + '/**/.polarion'
    Dir.glob(projects_path).each do |filename|
	  next  if filename == base_url + '/.polarion'
      Project.create(:url => filename)
	  Place.logger.info("created project with url #{filename}")
	end	
  end

  # Retrieve a specific project (based on url only)
  def retrieve
    start_time = Time.now.to_i

    Dir.glob("#{url}/polarion-project.xml").each do |filename|
	  content = IO.readlines(filename).join('')
	  doc = Nokogiri::XML(content)
	  
	  self.class.rules.each_pair do |k,v|
	    tmp = doc.xpath(v)
		self.send("#{k}=", tmp[0].content)  unless tmp[0].nil?		
	  end
	end
	self.save
	Place.logger.info("saved project with name #{self.name}")
	
	retrieve_parent_roles
	
	TimePoint.collect_all(url)
    timepoints.all.each{|tp| tp.retrieve}  if timepoints.size > 0
	
	WorkItem.collect_all(url)
    workitems.all.each{|wi| wi.retrieve}  if workitems.size > 0

	retrieve_participations

	users.each do |u|
	  # ugly way to prevent multiple (global) data retrieve :(
	  u.retrieve  if u.full_name.nil?
	  u.retrieve_watches
	end
	
	self.save
  end
  
  # Find a project by a given url (ending with +/.polarion+), +nil+ if not exists
  def self.find_by_url(url)
    projects = self.find(:url => url)
    projects.nil? ? nil : projects[0]
  end
  
  # Find a project by a given name, +nil+ if not exists
  def self.find_by_name(name)
    projects = self.find(:name => name)
    projects.nil? ? nil : projects[0]
  end
  
  # Find a project by a given perfix, +nil+ if not exists
  def self.find_by_prefix(prefix)
    projects = self.find(:prefix => prefix)
    projects.nil? ? nil : projects[0]
  end
  
  # Find all users involved in the project, eventually with a given role
  def users(with_role=nil)
    user_set = []
	if participations.size > 0
      participations.all.each do |pt|
	    unless with_role.nil?
  	      role = with_role.to_s
		  roles = pt.roles.size > 0 ? pt.roles.to_a : []
		  user_set << pt.user  if roles.include?(role)
	    else
  	      user_set << pt.user
	    end
	  end
	end
	user_set
  end
  
  # Find all roles used in the project
  def roles
    tmp = {}
    participations.all.each do |pt|
	  if pt.roles.size > 0
	    pt.roles.all.each{|r| tmp[r] = true}
	  end
	end
	tmp.keys
  end
  
private
  
  # Retrieve all participation of users in project, with its own roles
  def retrieve_participations
	Dir.glob("#{url}/security/user-roles.xml").each do |filename|
	  content = IO.readlines(filename).join
      doc = Nokogiri::XML(content)
	  doc.xpath('//user-roles/user').each do |udata|
	    u = User.find_by_name(udata['name'])
		unless u.nil?
		  p = Participation.create(:project => self, :user => u)
		  udata.xpath('role').map{|i| i['name']}.each{|r| p.roles << r}
		  p.save
		  Place.logger.info("saved participation: #{u.name}, #{self.name}")
		end
	  end
	end
  end
  
  # Retrieve parent roles' id for the project
  def retrieve_parent_roles
    local_path  = "#{url}/tracker/fields/workitem-link-role-enum.xml"
    _retrieve_parent_roles(local_path)
	
	# if they are not locally, find out globally
	global_path = "#{Place.conf['base']}/.polarion/tracker/fields/workitem-link-role-enum.xml"
	_retrieve_parent_roles(global_path)  if parent_roles.empty?
  end
    
  def _retrieve_parent_roles(path)
    Dir.glob(path).each do |filename|
	  content = IO.readlines(filename).join
	  doc = Nokogiri::XML(content)
	  doc.xpath('//enumeration/option[@parent="true"]').each do |data|
	    self.parent_roles << data.attributes['id'].to_s
	  end
	end
  end
  
end

end