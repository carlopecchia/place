
$: << File.join(File.dirname(__FILE__), '.')
require 'helper.rb'

class ProjectTest < Test::Unit::TestCase

  def setup
	@base = File.expand_path(File.join(File.dirname(__FILE__), 'repo'))
	Place.setup(@base)
	Place.gather!  
  end

  def teardown
    Ohm.flush
  end

  def test_collecting
    assert_not_nil @base
	assert_equal 2, Project.all.size
  end

  def test_find_by_name
	p = Project.find_by_name('P')
	assert_equal 'P', p.name
	assert_equal 'P', p.prefix
	assert_not_nil p.description
	
	p = Project.find_by_name 'NONE'
	assert_nil p
  end
  
  def test_find_by_url
	p = Project.find_by_url(@base + '/P/.polarion')
	assert_not_nil p
	
	b = Project.find_by_url(@base + '/A/B/.polarion')
	assert_not_nil b
	
	n = Project.find_by_url(@base + '/none/.polarion')
	assert_nil n
  end
  
  def test_find_by_prefix
	p = Project.find_by_prefix('P')
	assert_not_nil p
	
	p = Project.find_by_prefix('NONE')
	assert_nil p
  end
  
  def test_workitems
	p = Project.find_by_name('P')
	assert_not_nil p

	assert p.workitems.all.size > 0

	wi = p.workitems.all.first
	assert_not_nil wi
	assert_equal p, wi.project
  end
  
  def test_roles
    p = Project.find_by_name('P')
	assert_not_nil p
	
	assert p.roles.size > 0
	assert p.roles.include?('project_admin')
	assert !p.roles.include?('foo servant role')
  end
  
  def test_users
    p = Project.find_by_name('P')
	assert_not_nil p
	
	assert_equal 2, p.users.size
	assert_equal 1, p.users('project_admin').size
	
	u = User.find_by_name 'alice'
	assert_not_nil u
	assert_equal u, p.users('project_admin').first
  end
  
  def test_parent_roles
	p = Project.find_by_name('P')
	assert_not_nil p

	assert ! p.parent_roles.empty?
	assert p.parent_roles.include?('parent')
	assert p.parent_roles.include?('refines')
	assert ! p.parent_roles.include?('depends')

    # A/B doesn't have a local file for workitem-link-roles	
	b = Project.find_by_url(@base + '/A/B/.polarion')
	assert_not_nil b
	assert ! b.parent_roles.empty?
	assert b.parent_roles.include?('parent')
	assert_equal 1, b.parent_roles.size 
  end

end
