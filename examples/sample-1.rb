
require 'rubygems'
require 'place'

include Place

# this path refers to (root) repository local working copy
Place.setup('../test/repo')

Place.logger_setup('/dev/null')

# that is not necessary each time!
Place.gather!

puts "Retrieved #{Project.all.size} projects."
puts "Retrieved #{WorkItem.all.size} workitems."

tasks = WorkItem.find_by_type :task
puts "  tasks: #{tasks.size}"

puts "-" * 60

# for each task print: ID, title and list of linked in workitems
tasks.each do |t|
  printf("[%4s] - %-10s (%s)\n", t.wid, t[:title], t.links_in.map{|l| l.from.wid}.join(', '))
end

puts "-" * 60

# do the same, but only in a project context
p = Project.find_by_name('P')
p.workitems(:type => :taks).each do |t|
  printf("[%4s] - %-10s (%s)\n", t.wid, t[:title], t.links_in.map{|l| l.from.wid}.join(', '))
end
