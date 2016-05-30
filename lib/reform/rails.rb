require "reform/rails/version"

require "reform"
require "reform/form/active_model"
require "reform/form/active_model/validations"

require "reform/active_record" if defined?(ActiveRecord)
require "reform/mongoid" if defined?(Mongoid)

Reform::Form.class_eval do
  include Reform::Form::ActiveModel
  include Reform::Form::ActiveModel::FormBuilderMethods
  include Reform::Form::ActiveRecord if defined?(ActiveRecord)
  include Reform::Form::Mongoid if defined?(Mongoid)
  include Reform::Form::ActiveModel::Validations
end

module Reform
  def self.rails3_0?
    ::ActiveModel::VERSION::MAJOR == 3 and ::ActiveModel::VERSION::MINOR == 0
  end
end
