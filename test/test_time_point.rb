
$: << File.join(File.dirname(__FILE__), '.')
require 'helper.rb'

class TimePointTest < Test::Unit::TestCase

  def setup
	base = File.expand_path(File.join(File.dirname(__FILE__), 'repo'))
	Place.setup(base)
	Place.gather!
	@prj = Project.find_by_name('P')
  end

  def teardown
    Ohm.flush
  end

  def test_environment
    assert_not_nil @prj
	assert_equal 2, @prj.timepoints.all.size
  end
  
  def test_retrieving
	@prj.timepoints.all.each do |tp|
	  assert_not_nil tp.url
	  assert_not_nil tp.tid
	  assert_not_nil tp.name
	  assert_not_nil tp.time
	end
  end
  
  def test_belongs_to_project
	tp = @prj.timepoints.all.first
	assert_not_nil tp
	assert_not_nil tp.project
	assert_equal @prj, tp.project
  end
  
  def test_workitems
    # TODO a timepoint has workitems
  end
  
  def test_find_by_tid
    tp = @prj.timepoints.all.first
	assert_equal tp, TimePoint.find_by_tid(tp.tid)
	
	assert_nil TimePoint.find_by_tid('fooz none')
	assert_nil TimePoint.find_by_tid(nil)
  end
end
