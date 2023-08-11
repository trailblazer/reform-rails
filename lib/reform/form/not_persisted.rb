# Support nil models (aka reform without backed model)
module Reform::Form::NotPersisted
  def self.included(base)
    base.class_eval do
      register_feature Reform::Form::NotPersisted

      def persisted?
        false
      end

      def to_key
        nil # see http://apidock.com/rails/ActiveModel/Conversion/to_key : nil if no key attributes
      end

      def to_param
        nil # see http://apidock.com/rails/ActiveModel/Conversion/to_param : nil if not persisted
      end

      def id
        nil
      end

    end
  end
end

