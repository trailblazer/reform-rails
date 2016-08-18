require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = false
end

task :default => :test

namespace :test do
  desc 'Test against all supported Rails versions'
  task :all do
    %w(3.2 4.0 4.1 4.2).each do |version|
      `BUNDLE_GEMFILE='gemfiles/Gemfile.rails-#{version}' bundle install --quiet`
      `BUNDLE_GEMFILE='gemfiles/Gemfile.rails-#{version}' bundle exec rake test`
    end
  end
end