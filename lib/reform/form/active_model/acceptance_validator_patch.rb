module Reform::Form::ActiveModel
  module AcceptanceValidatorPatch
    def self.apply!
      return if defined?(::ActiveModel::Validations::ReformAcceptanceValidator)

      klass = Class.new(::ActiveModel::EachValidator) do
        def initialize(options)
          super({ allow_nil: true, accept: ["1", true] }.merge!(options))
        end

        def validate_each(record, attribute, value)
          unless acceptable_option?(value)
            if Gem::Version.new(::ActiveModel::VERSION::STRING) >= Gem::Version.new('6.1.0')
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

      # Assign the class to a constant for tracking
      ::ActiveModel::Validations.const_set(:ReformAcceptanceValidator, klass)

      # Override the built-in validator
      ::ActiveModel::Validations.send(:remove_const, :AcceptanceValidator)
      ::ActiveModel::Validations.const_set(:AcceptanceValidator, klass)
    end
  end
end
