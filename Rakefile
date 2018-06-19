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

namespace :stylecheck do
  task :ruby do
    system 'bundle exec rubocop -D'
  end

  task :python do
    system 'pycodestyle scripts/'
  end
end
