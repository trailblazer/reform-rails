git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

source "https://rubygems.org"
gemspec

# gem "reform", github: "trailblazer/reform"
gem 'reform', git: 'https://github.com/samstickland/reform', branch: '2.2.5'

rails_version = ENV.fetch("RAILS_VERSION", "5.2.0")

# bored of wrestling with rails...
if rails_version == "4.0"
  gem "mongoid", "~> 4"
else
  gem "mongoid", "< 7.0"
end

gem "activerecord", "~> #{rails_version}"
gem "railties", "~> #{rails_version}"
gem "sqlite3"
puts "Rails version #{rails_version}"
if rails_version == "5.0.0"
  gem "minitest", "5.10.3"
else
  gem "minitest"
end
