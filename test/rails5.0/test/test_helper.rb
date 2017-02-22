ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

Rails.backtrace_cleaner.remove_silencers! # YES, stacktraces are awesome!
