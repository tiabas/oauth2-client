$:.unshift File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../examples', __FILE__)

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'examples'
  t.libs << 'test'
  t.verbose = true
end

desc "Run tests"
task :default => :test
