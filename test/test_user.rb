
$: << File.join(File.dirname(__FILE__), '.')
require 'helper.rb'

class UserTest < Test::Unit::TestCase

  def setup
	Place.setup(File.expand_path(File.join(File.dirname(__FILE__), 'repo')))
	Place.gather!
  end

  def teardown
    Ohm.flush
  end

  def test_collecting
	assert_equal 2, User.all.size
  end
    
  def test_find_by_name
    assert_not_nil User.find_by_name('alice')
    assert_nil User.find_by_name('foo')
  end

  def test_watches
	User.all.each{|u| u.retrieve_watches }

	User.all.each do |u|
	  assert u.watches.size > 0
	end
  end
  
  def test_author_of
	alice = User.find_by_name('alice')
	assert_equal 5, alice.author_of.size
	assert alice.author_of.map{|wi| wi.wid}.include?('P-1')
  end
  
  def test_participations
    alice = User.find_by_name('alice')
	assert_not_nil alice.participations
	assert_equal 1, alice.participations.size
	
	prj = Project.find_by_name('P')
	assert_not_nil prj
	assert_equal prj, alice.participations.first.project
	
	roles = alice.participations.first.roles
	assert roles.include?('project_admin')
  end
end
