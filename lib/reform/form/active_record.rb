require "reform/form/orm"

module Reform::Form::ActiveRecord
  def self.included(base)
    base.class_eval do
      register_feature Reform::Form::ActiveRecord
      include Reform::Form::ActiveModel
      include Reform::Form::ORM
      extend ClassMethods
    end
  end

  module ClassMethods
    def validates_uniqueness_of(attribute, options={})
      options = options.merge(:attributes => [attribute])
      validates_with(UniquenessValidator, options)
    end

    def i18n_scope
      :activerecord
    end

    def human_attribute_name(*args)
      if model_class
        model_class.human_attribute_name(*args)
      else
        super
      end
    end

    def model_class
      @model_class ||=
        if Object.const_defined?(model_name.to_s)
          Object.const_get(model_name.to_s)
        else
          nil
        end
    end
  end

  def to_nested_hash(*)
    super.with_indifferent_access
  end

  class UniquenessValidator < ::ActiveRecord::Validations::UniquenessValidator
    include Reform::Form::ORM::UniquenessValidator
  end
end
