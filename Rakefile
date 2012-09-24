$LOAD_PATH << File.dirname(__FILE__) + '/lib'
$LOAD_PATH << File.dirname(__FILE__) + '/examples'

require 'oauth2'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.verbose = true
end

desc "Run tests"
task :default => :test
