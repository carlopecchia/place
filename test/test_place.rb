
$: << File.join(File.dirname(__FILE__), '.')
require 'helper.rb'

class PlaceTest < Test::Unit::TestCase

  def teardown
    Ohm.flush
  end	
  
  def test_gather
	base = File.expand_path(File.join(File.dirname(__FILE__), 'repo'))
	Place.setup(base)
	Place.gather!
	
	assert_equal 2, Project.all.size
  end
  
  def test_duration
	assert_equal  11, to_hours('1d 3h')
	assert_equal  16, to_hours('2d')
	assert_equal   3, to_hours('3h')
	assert_equal 0.5, to_hours('1/2h')
	assert_equal   4, to_hours('1/2d')
	assert_equal   0, to_hours('')
	assert_equal nil, to_hours(nil)
  end
end
