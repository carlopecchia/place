
Gem::Specification.new do |s|
  s.name              = "place"
  s.version           = "0.1.1"
  s.summary           = "Polarion Lace: Polarion items access in Ruby"
  s.description		  = <<-EOF
    Extract information from Polarion and turns it into easy manageable ruby objects.
	
	Those objects are stored via Redis.
  EOF
  s.authors           = ["Carlo Pecchia"]
  s.email             = ["c.pecchia@gmail.com"]
  s.homepage          = "http://github.com/carlopecchia/place"
  s.add_dependency('json')
  s.add_dependency('ohm')
  s.add_dependency('nokogiri')
  s.files = ["Changelog", "LICENSE", "README.markdown", "Technical.markdown", "Rakefile", "lib/place.rb", "lib/place/project.rb", "lib/place/link.rb", "lib/place/participation.rb", "lib/place/user.rb", "lib/place/time_point.rb", "lib/place/work_item.rb", "lib/place/work_record.rb", "lib/place/comment.rb", "place.gemspec", "test/test_project.rb", "test/helper.rb", "test/test_workitem.rb", "test/test_time_point.rb", "test/test_place.rb", "test/test_comment.rb", "test/test_user.rb", "examples/sample-1.rb"]
end

