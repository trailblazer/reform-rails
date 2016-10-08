require "reform/form/orm"

module Reform::Form::ActiveRecord
  def self.included(base)
    base.class_eval do
      register_feature Reform::Form::ActiveRecord
      include Reform::Form::ActiveModel
      include Reform::Form::ORM
      extend ClassMethods

      class << self
        def i18n_scope
          :activerecord
        end
      end
    end
  end

  module ClassMethods
    def validates_uniqueness_of(attribute, options={})
      options = options.merge(:attributes => [attribute])
      validates_with(UniquenessValidator, options)
    end
  end

  def to_nested_hash(*)
    super.with_indifferent_access
  end

  class UniquenessValidator < ::ActiveRecord::Validations::UniquenessValidator
    include Reform::Form::ORM::UniquenessValidator
  end
end
