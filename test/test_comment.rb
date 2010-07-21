
$: << File.join(File.dirname(__FILE__), '.')
require 'helper.rb'

class CommentTest < Test::Unit::TestCase

  def setup
	Place.setup(File.expand_path(File.join(File.dirname(__FILE__), 'repo')))
	Place.gather!
  end

  def teardown
    Ohm.flush
  end

  def test_environment
	Comment.all.each do |c|
	  assert_not_nil c.author
	  assert_not_nil c.workitem
	  assert_not_nil c.text
	  assert_not_nil c.created
	end
  end
  
  def test_find_by_cid
	assert_not_nil Comment.find_by_cid('P-6#1')
	assert_nil Comment.find_by_cid('P-6#z00')
  end
  
  def test_parent
	c = Comment.find_by_cid('P-6#2')
	assert_not_nil c.parent
	assert_equal Comment.find_by_cid('P-6#1'), c.parent
  end
end
