#Rakefile
require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = true
end

desc "Run spec"
task :default => :spec
task :test    => :spec
