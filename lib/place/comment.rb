module Place

# Each Comment belongs to a WorkItem and is written by a User
class Comment < Ohm::Model
  attribute :url
  index :url
  
  attribute :title
  attribute :created
  attribute :text
  attribute :parentComment
  
  collection :child, Comment, :parent
  
  reference :parent, Comment
  reference :author, User
  reference :workitem, WorkItem

  class << self; attr_accessor :rules end
  @rules = {
    'title'			=> '//comment/field[@id="title"]',
	'author'		=> '//comment/field[@id="author"]',
	'text'			=> '//comment/field[@id="text"]',
	'created'		=> '//comment/field[@id="created"]',
	'parentComment'	=> '//comment/field[@id="parentComment"]'
  }

  # Retrieve a specific comment data
  def retrieve
    content = IO.readlines(url).join('')
	doc = Nokogiri::XML(content)
	self.class.rules.each_pair do |k,v|
	  tmp = doc.xpath(v)

	  case k
		when 'author'
		  self.send("#{k}=", User.find_by_name(tmp[0].content))
		else
		  self.send("#{k}=", tmp[0].content)  unless tmp[0].nil?		
	  end
	end
	self.workitem = WorkItem.find_by_wid(File.dirname(self.url).split(/\//).last)
	self.parent   = Comment.find_by_cid(self.parentComment) unless self.parentComment.nil?
	Place.logger.info("retrieved comement for #{self.url}")
    self.save
  end
  
  # Find a comment by a "comment-id" (es: P-1#3)
  def self.find_by_cid(cid)
    comments = self.all.select do |c|
	  chunks = c.url.split('/')
	  wid = chunks[-2]
	  comment_part = chunks[-1]
	  comment_part =~ /comment-(\d+).xml/
	  "#{wid}##{$1}" == cid
	end
	return comments.first  if comments.size > 0
    return nil
  end
  
  # Return a calculated cid for the comment
  def cid
    chunks = self.url.split('/')
	wid = chunks[-2]
	comment_part = chunks[-1]
	comment_part =~ /comment-(\d+).xml/
	"#{wid}#{$1}"
  end
  
end

end



  
