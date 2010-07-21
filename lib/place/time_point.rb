module Place

# A TimePoint is a "named milestone"
class TimePoint < Ohm::Model
  attribute :tid
  index :tid
  attribute :url
  
  attribute :name
  attribute :time
  attribute :description
  
  reference :project, Project
  
  collection :workitems, WorkItem, :timepoint
    
  class << self; attr_accessor :rules end
  @rules = {
    'name'			=> '//time-point/field[@id="name"]',
	'description'	=> '//time-point/field[@id="description"]',
	'time'			=> '//time-point/field[@id="time"]'
  }

  # Collect all timepoints (url) under a given project url
  def self.collect_all(base_url)
    Dir.glob(base_url + '/tracker/timepoints/*.xml').each do |filename|
	  TimePoint.create(
		:tid		=> File.basename(filename, '.xml'),
		:url		=> filename,
		:project	=> Project.find_by_url(base_url)
	  )
	  Place.logger.info("collected timepoint at #{filename}")
	end
  end
  
  # Retrieve a specific timepoint data (name, time, description)
  def retrieve
    content = IO.readlines(url).join('')
	doc = Nokogiri::XML(content)
	self.class.rules.each_pair do |k,v|
	  tmp = doc.xpath(v)
	  self.send("#{k}=", tmp[0].content)  unless tmp[0].nil?		
	end
	Place.logger.info("retrieved timepoint #{self.url}")
    self.save
  end
  
  def self.find_by_tid(tid)
    return nil  if tid.nil?
    tps = self.find(:tid => tid.to_s)
	tps.nil? ? nil : tps[0]
  end
end

end
