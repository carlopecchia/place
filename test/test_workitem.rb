
$: << File.join(File.dirname(__FILE__), '.')
require 'helper.rb'

class WorkItemTest < Test::Unit::TestCase

  def setup
	Place.setup(File.expand_path(File.join(File.dirname(__FILE__), 'repo')))
	Place.gather!
  end

  def teardown
    Ohm.flush
  end

  def test_environment
    assert WorkItem.all.size > 0
	WorkItem.all.each do |wi|
	  assert_not_nil wi.url
	  assert_not_nil wi.wid
	  assert_not_nil wi.type
	  assert_not_nil wi.fields
	end
  end

  
  def test_project
    p = Project.find_by_prefix('P')
	assert_not_nil p

	wi = p.workitems.all.first
	assert_not_nil wi
	
	assert_equal p, wi.project
  end
  

  def test_fields
    p = Project.find_by_prefix('P')
	assert_not_nil p
  
    wi = p.workitems.all.first
    assert_not_nil wi
    assert_not_nil wi[:type]
	assert_not_nil wi.type
    
    assert_nil wi[:foo]
    wi[:foo] = 'bar'
    assert_equal 'bar', wi[:foo]
  end

  def test_find_by_wid
    wi = WorkItem.find_by_wid 'P-1'
    assert_not_nil wi
    assert_equal 'task', wi[:type]
    assert_equal 'task', wi.type
  end

  def test_find_by_type
    assert_equal 7, WorkItem.find_by_type(:task).size
    assert_equal 1, WorkItem.find_by_type(:pr).size
    
    wi = WorkItem.find_by_type(:task).first
    assert_equal 'task', wi.type
    
    wi = WorkItem.find_by_type(:foo).first
    assert_nil wi
  end

  def test_author
    u = User.find_by_name('alice')
    assert_not_nil u
    
    wi = WorkItem.find_by_wid('P-1')
    assert_not_nil wi
        
    assert_not_nil wi.author
    assert_equal wi.author, u
  end

  def test_assignees
	# no assignee
	wi = WorkItem.find_by_wid('P-4')
	assert_equal 0, wi.assignees.size
	
	# single assignee
	wi = WorkItem.find_by_wid('P-1')
	assert_equal 1, wi.assignees.size
	
	# more than one assignee
	wi = WorkItem.find_by_wid('P-3')
	assert wi.assignees.size > 1	
  end

  def test_links
	p3 = WorkItem.find_by_wid('P-3')
	assert_not_nil p3
	
	assert_equal 2, p3.links_in.size
	
	p3.links_in.map{|l| l.from.wid}.each do |wid|
	  assert ['P-5', 'P-6'].include?(wid)
	end
	
	p3.links_out.map{|l| l.to.wid}.each do |wid|
	  assert ['P-1'].include?(wid)
	end
	
	p7 = WorkItem.find_by_wid('P-7')
	assert_not_nil p7
	assert_equal 0, p7.links_in.size
	assert_equal 0, p7.links_out.size
  end

  def test_watches
	# no watches
	wi = WorkItem.find_by_wid('P-4')
	assert_equal 0, wi.watches.size

	# one watches
	wi = WorkItem.find_by_wid('P-2')
	assert_equal 1, wi.watches.size
	
	# more tha one watches
	wi = WorkItem.find_by_wid('P-1')
	assert wi.watches.size > 1
  end
  
  def test_workrecords
    # every workitems has (at least empty) workrecords
    WorkItem.all.each do |wi|
	  assert_not_nil wi.workrecords
	end
	
	# one workrecord
	p3 = WorkItem.find_by_wid('P-3')
	assert_equal 1, p3.workrecords.size

	# more workrecords
	p6 = WorkItem.find_by_wid('P-6')
	assert_equal 2, p6.workrecords.size
  end
  
  def test_comments
    # every workitems has (at least empty) comments
    WorkItem.all.each do |wi|
	  assert_not_nil wi.comments
	end
  
    # no comments
	p3 = WorkItem.find_by_wid('P-3')
	assert_equal 0, p3.comments.size

	# more comments
    p6 = WorkItem.find_by_wid('P-6')
	assert_equal 2, p6.comments.size
  end
  
  def test_total_on_timeSpent
    p1 = WorkItem.find_by_wid('P-1')
	assert_equal 1, p1['timeSpent']
	
	p3 = WorkItem.find_by_wid('P-3')
	assert_equal 2, p3['timeSpent']
	
	p6 = WorkItem.find_by_wid('P-6')
	assert_equal 4, p6['timeSpent']
	
	assert_equal 7, p1.total_on('timeSpent')
  end  
  
end
