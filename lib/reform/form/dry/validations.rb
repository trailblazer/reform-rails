module Reform::Form::Dry
  module Validations
    class Group
      def initialize(options = {})
        options ||= {}
        schema_class = options[:schema] || BaseSchema
        @validator = Dry::Validation.Schema(schema_class, build: false)

        @schema_inject_params = options[:with] || {}
      end
    end

    class BaseSchema < Dry::Validation::Schema
      config.messages_file = "config/locales/errors.#{I18n.locale}.yml"
      config.messages = :i18n
    end
  end
end
