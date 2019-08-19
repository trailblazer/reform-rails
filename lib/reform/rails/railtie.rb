module Reform
  module Rails
    class Railtie < ::Rails::Railtie
      config.reform = ActiveSupport::OrderedOptions.new

      initializer "reform.form_extensions", after: :load_config_initializers do
        validations = config.reform.validations || :active_model

        require "reform/form/multi_parameter_attributes"

        if validations == :active_model
          active_model!
        elsif validations == :dry
          enable_form_builder_methods = config.reform.enable_active_model_builder_methods || false

          dry!(enable_form_builder_methods)
        else
          warn "[Reform::Rails] No validation backend set. Please do so via `config.reform.validations = :active_model`."
        end
      end

      def active_model!
        require "reform/form/active_model/form_builder_methods"
        require "reform/form/active_model"

        require "reform/form/active_model/model_validations"
        require "reform/form/active_model/validations"

        require "reform/active_record" if defined?(::ActiveRecord)
        require "reform/mongoid" if defined?(::Mongoid)

        Reform::Form.class_eval do
          include Reform::Form::ActiveModel
          include Reform::Form::ActiveModel::FormBuilderMethods
          include Reform::Form::ActiveRecord if defined?(::ActiveRecord)
          include Reform::Form::Mongoid if defined?(::Mongoid)
          include Reform::Form::ActiveModel::Validations
        end
      end

      def dry!(enable_am = true)
        if enable_am
          require "reform/form/active_model/form_builder_methods" # this is for simple_form, etc.

          # This adds Form#persisted? and all the other crap #form_for depends on. Grrrr.
          require "reform/form/active_model" # DISCUSS: only when using simple_form.
        end

        require "reform/form/dry"

        Reform::Form.class_eval do
          if enable_am
            include Reform::Form::ActiveModel
            include Reform::Form::ActiveModel::FormBuilderMethods
          end

          include Reform::Form::Dry
        end
      end
    end # Railtie
  end
end
