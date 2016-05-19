require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require

module Dummy
  class Application < Rails::Application
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.cache_store = :memory_store
  end
end

#require "reform/rails" # FIXME: this has to happen automatically in the rake test_rails run.
