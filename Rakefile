
require 'rake/testtask'

desc "Run tests"
Rake::TestTask.new do |t|
  t.test_files = FileList['test/test_*.rb']
end

task :default => [:test]
