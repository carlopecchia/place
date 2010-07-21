module Place

# Each WorkRecord ties a User to a WorkItem, with a +time_spent+, +date+ plus a +type+ and a +comment+
class WorkRecord < Ohm::Model
  attribute :url
  index :url

  attribute :time_spent
  attribute :date
  attribute :type
  attribute :comment

  reference :user, User
  reference :workitem, WorkItem

  class << self; attr_accessor :rules end
  @rules = {
    'time_spent'	=> '//work-record/field[@id="timeSpent"]',
	'date'			=> '//work-record/field[@id="date"]',
	'type'			=> '//work-record/field[@id="type"]',
	'comment'		=> '//work-record/field[@id="comment"]',
	'user'			=> '//work-record/field[@id="user"]'
  }

  # Retrieve a specific workrecord data (time_spent, date, user, workitem) + (type, comment)
  def retrieve
    content = IO.readlines(url).join('')
	doc = Nokogiri::XML(content)
	self.class.rules.each_pair do |k,v|
	  tmp = doc.xpath(v)

	  case k
	    when 'time_spent'
		  self.send("#{k}=", to_hours(tmp[0].content))
		when 'user'
		  self.send("#{k}=", User.find_by_name(tmp[0].content))
		else
		  self.send("#{k}=", tmp[0].content)  unless tmp[0].nil?		
	  end
	end
	
	self.workitem = WorkItem.find_by_wid(File.dirname(self.url).split(/\//).last)
	
	Place.logger.info("saved workrecord #{self.url}")
	
    self.save
  end
end


end