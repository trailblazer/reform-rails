$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'reform/rails'

require 'minitest/autorun'

require "rails-app/config/environment"

require "reform/form/active_model/validations"
Reform::Contract.class_eval do
  feature Reform::Form::ActiveModel::Validations
end
# FIXME!
Reform::Form.class_eval do
  feature Reform::Form::ActiveModel::Validations
end
