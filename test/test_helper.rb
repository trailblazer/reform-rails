$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV["RAILS_ENV"] = "test"

require 'reform/rails'

require 'minitest/autorun'

require "rails-app/config/environment"
require "rails/test_help"
require 'minitest/spec'
