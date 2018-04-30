source 'https://rubygems.org'
gemspec

if ENV['USE_LOCAL_GEMS']
  gem "reform", path: "../reform"
else
  gem "reform", github: "trailblazer/reform"
end

rails_version = ENV.fetch('RAILS_VERSION', '5.2.0')

# bored of wrestling with rails...
if rails_version == '4.0'
  gem 'mongoid', '~> 4'
else
  gem 'mongoid', '< 7.0'
end

gem "railties", "~> #{rails_version}"
gem "activerecord", "~> #{rails_version}"
gem "sqlite3"
puts "Rails version #{rails_version}"
if rails_version == '5.0.0'
  gem 'minitest', '5.10.3'
else
  gem "minitest"
end

