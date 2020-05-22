git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

source "https://rubygems.org"
gemspec

gem 'pry-byebug'
gem "minitest-line"

case ENV["GEMS_SOURCE"]
  when "local"
    gem "reform", path: "../reform"
  when "github"
    gem "reform", github: "trailblazer/reform"
end

rails_version = ENV.fetch("RAILS_VERSION", "6.0.0")

# bored of wrestling with rails...

gem("mongoid", "< 7.0") unless rails_version.include?('6.0')


gem "activerecord", "~> #{rails_version}"
gem "railties", "~> #{rails_version}"
if rails_version.include?('6.0')
  gem "sqlite3", "~> 1.4"
else
  gem "sqlite3", "~> 1.3", "< 1.4"
end
puts "Rails version #{rails_version}"
