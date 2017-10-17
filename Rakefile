namespace :man_pages do
  task :build do
    puts '  Building man pages'
    system 'ronn man/*.md'
  end
end

namespace :gem do
  task :build => ['man_pages:build'] do
    system 'gem build trollolo.gemspec'
  end
end
