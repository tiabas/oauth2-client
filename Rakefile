#Rakefile
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do
  config.rcov = true
end

desc "Run spec"
task :default => :spec

task :test => :spec
