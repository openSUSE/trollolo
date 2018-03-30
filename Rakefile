namespace :man_pages do
  task :build do
    puts '  Building man pages'
    system 'ronn man/*.md'
  end
end

namespace :gem do
  task build: ['man_pages:build'] do
    system 'gem build trollolo.gemspec'
  end
end

require 'rubocop/rake_task'
require 'rspec/core/rake_task'

task default: %i[rubocop spec]

desc 'Run tests'
task :spec do
  RSpec::Core::RakeTask.new
end

desc 'Run rubocop'
task :rubocop do
  RuboCop::RakeTask.new do |t|
    t.options = ['--display-cop-names']
  end
end
