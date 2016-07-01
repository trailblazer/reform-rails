module Reform
  module Rails
    class Railtie < ::Rails::Railtie
      config.reform = ActiveSupport::OrderedOptions.new

      initializer "reform.form_extensions", after: :load_config_initializers do
        validations = config.reform.validations || :active_model

        if validations == :active_model
          active_model!
        elsif validations == :dry
          dry!
        else
          warn "[Reform::Rails] No validation backend set. Please do so via `config.reform.validations = :active_model`."
        end
      end

      def active_model!
        require "reform"
        require "reform/form/active_model/model_validations"
        require "reform/form/active_model/form_builder_methods"
        require "reform/form/active_model"
        require "reform/form/active_model/validations"
        require "reform/form/multi_parameter_attributes"

        require "reform/active_record" if defined?(ActiveRecord)
        require "reform/mongoid" if defined?(Mongoid)

        Reform::Form.class_eval do
          include Reform::Form::ActiveModel
          include Reform::Form::ActiveModel::FormBuilderMethods
          include Reform::Form::ActiveRecord if defined?(ActiveRecord)
          include Reform::Form::Mongoid if defined?(Mongoid)
          include Reform::Form::ActiveModel::Validations
        end
      end

      def dry!
        require "reform"
        require "reform/form/dry"

        require "reform/form/multi_parameter_attributes"
        require "reform/form/active_model/form_builder_methods" # this is for simple_form, etc.

        # This adds Form#persisted? and all the other crap #form_for depends on. Grrrr.
        require "reform/form/active_model" # DISCUSS: only when using simple_form.

        Reform::Form.class_eval do
          include Reform::Form::ActiveModel # DISCUSS: only when using simple_form.
          include Reform::Form::ActiveModel::FormBuilderMethods

          include Reform::Form::Dry
        end
      end
    end # Railtie
  end
end
