require "reform/rails/version"
require 'reform'
require "reform/rails/railtie"

module Reform
end

module ActiveModel
  module Validations
    class AcceptanceValidator < EachValidator # :nodoc:
      def initialize(options)
        super({ allow_nil: true, accept: ["1", true] }.merge!(options))
      end

      def validate_each(record, attribute, value)
        unless acceptable_option?(value)
          if Gem::Version.new(ActiveModel::VERSION::STRING) >= Gem::Version.new('6.1.0')
            record.errors.add(attribute, :accepted, **options.except(:accept, :allow_nil))
          else
            record.errors.add(attribute, :accepted, options.except(:accept, :allow_nil))
          end
        end
      end

      private

        def acceptable_option?(value)
          Array(options[:accept]).include?(value)
        end
    end
  end
end
