require 'rubygems'

require 'ohm'
require 'nokogiri'
require 'json'
require 'logger'


require File.join(File.dirname(__FILE__), 'place', 'project')
require File.join(File.dirname(__FILE__), 'place', 'time_point')
require File.join(File.dirname(__FILE__), 'place', 'user')
require File.join(File.dirname(__FILE__), 'place', 'work_item')
require File.join(File.dirname(__FILE__), 'place', 'work_record')
require File.join(File.dirname(__FILE__), 'place', 'comment')
require File.join(File.dirname(__FILE__), 'place', 'link')
require File.join(File.dirname(__FILE__), 'place', 'participation')


module Place
  VERSION = '0.1.0'

  @conf = {}
  
  def self.setup(repository_path)
    @conf['base'] = repository_path
	Ohm.connect
  end
  
  def self.conf
    @conf
  end
  
  def self.logger
    @log
  end  
  
  def self.logger_setup(filename=nil)
    unless filename.nil?
      @log = Logger.new(filename)
    else	  
      @log = Logger.new(STDERR)
	end
	@log.level = Logger::INFO   
  end
  
  # Collect and retrieve all repo information, for each contained project
  # If a project url is specified, it retrieves only info on this project
  # BEWARE: each gather flush the whole database!
  def gather!(project_url=nil)
    start_time = Time.now.to_i
	
    path = @conf['base']  # without ending '.polarion'
    Ohm.flush
	
	Project.collect_all(path)
    User.collect_all(path)
	
	unless project_url.nil?
	  prj = Project.find_by_url(project_url)
	  prj.retrieve
	else
      Project.all.each{|prj| prj.retrieve}
	end
	
	Ohm.redis.set 'updated_duration', Time.now.to_i - start_time
  end

  # Write last update timespent for the whole database  
  def updated!
    Ohm.redis.set 'updated', Time.now.strftime("%d.%m.%Y %H:%M:%S")
  end
  
  def updated_at
    Ohm.redis.get 'updated'
  end
  
  def updated?
    not updated_at.nil?
  end
  
  def updated_duration
    Ohm.redis.get 'updated_duration'
  end
  
  def reset!
    Ohm.flush
  end

  # from duration to number of hours (1d == 8h)
  def to_hours(duration)
    return nil if duration.nil?
	# TODO with a case statement or another regexp?
    if duration =~ /(\d+)d\s(\d+)h/
      days, hours = $1.to_f, $2.to_f
	elsif duration =~ /(\d+)\/(\d+)d/
	  days = $1.to_f / $2.to_f
	  hours = 0
	elsif duration =~ /(\d+)\/(\d+)h/
	  days = 0
	  hours = $1.to_f / $2.to_f
    elsif duration =~ /(\d+)d/
	  days, hours = $1.to_f, 0
    elsif duration =~ /(\d+)h/
	  days, hours =  0, $1.to_f
    else
	  days, hours =  0, 0
    end

    (8*days + hours)
  end

end
