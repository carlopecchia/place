module Place

# A User is an account under Polarion
class User < Ohm::Model
  attribute :name
  index :name
  attribute :url
  
  attribute :full_name
  attribute :description
  attribute :email

  collection :workrecords, WorkRecord, :user
  collection :comments, Comment, :author

  set :watches, WorkItem
  collection :author_of, WorkItem, :author
  set :assignments, WorkItem
  
  collection :participations, Participation, :user

  
  # Collect all users (name, url) under a given repository url
  def self.collect_all(base_url)
    Dir.glob(base_url + '/.polarion/user-management/users/**/user.xml').each do |filename|
	  User.create(
		:name	=> File.dirname(filename).split(/\//).last,
		:url	=> filename
	  )
	  Place.logger.info("collected user at #{filename}")
	end
  end
  
  class << self; attr_accessor :rules end
  @rules = {
    'full_name'   => '//user/field[@id="name"]',
	'description' => '//user/field[@id="description"]',
	'email'       => '//user/field[@id="email"]'
  }
  
  # Retrieve a specific user data (based on name and url only)
  def retrieve
    content = IO.readlines(url).join('')
    doc = Nokogiri::XML(content)
	self.class.rules.each_pair do |k,v|
	  tmp = doc.xpath(v)
	  self.send("#{k}=", tmp[0].content)  unless tmp[0].nil?		
	end
	Place.logger.info("retrieved user at #{self.name}")
	self.save
  end
  
  def retrieve_watches
    content = IO.readlines(url).join('')
	doc = Nokogiri::XML(content)
    doc.xpath('//user/field[@id="watches"]/list//item').each do |wa|
	  prj, wid = wa.text.split('$')
	  if Project.all.map{|p| p.name}.include?(prj)
	    wi = WorkItem.find_by_wid(wid)
		unless wi.nil?
		  wi.watches << User.find_by_name(name)
		  wi.save
		  self.watches << wi
		  self.save
		end
	  end
	end
	Place.logger.info("retrieved watches for user #{self.name}")
	self
  end
  
  # Find a user by the given name, returns +nil+ if not present
  def self.find_by_name(name)
    users = self.find(:name => name.to_s)
	  users.nil? ? nil : users[0]
  end
end

end