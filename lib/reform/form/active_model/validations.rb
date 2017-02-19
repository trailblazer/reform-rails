require "active_model"
require "reform/form/active_model"
require "uber/delegates"

module Reform
  module Form::ActiveModel
  # AM::Validations for your form.
  # Provides ::validates, ::validate, #validate, and #valid?.
  #
  # Most of this file contains unnecessary wiring to make ActiveModel's error message magic work.
  # Since Rails still thinks it's a good idea to do things like object.class.human_attribute_name,
  # we have some hacks in here to provide that. If it doesn't work for you, don't blame us.
    module Validations
      def self.included(includer)
        includer.instance_eval do
          include Reform::Form::ActiveModel

          class << self
            extend Uber::Delegates
            # # Hooray! Delegate translation back to Reform's Validator class which contains AM::Validations.
            delegates :active_model_really_sucks, :human_attribute_name, :lookup_ancestors, :i18n_scope # Rails 3.1.

            def validation_group_class
              Group
            end

            # this is to allow calls like Form::human_attribute_name (note that this is on the CLASS level) to be resolved.
            # those calls happen when adding errors in a custom validation method, which is defined on the form (as an instance method).
            def active_model_really_sucks
              Class.new(Validator).tap do |v|
                v.model_name = model_name
              end
            end
          end
        end # ::included
      end

      # The concept of "composition" has still not arrived in Rails core and they rely on 400 methods being
      # available in one object. This is why we need to provide parts of the I18N API in the form.
      def read_attribute_for_validation(name)
        send(name)
      end

      def errors(*args)
        @amv_errors
      end

      def validate!(params, pointers=[])
        @amv_errors = Result::Errors.new(self) # Errors < AMV::Errors, so we have identical API.

        super.tap do
          # @fran: super ugly hack thanks to the shit architecture of AMV. let's drop it in 3.0 and move on!
          all_errors = @result.instance_variable_get(:@results)
          all_errors += [@amv_errors] if @amv_errors.any?

          @result = Reform::Contract::Result.new(all_errors)
          @amv_errors = Result::ResultErrors.new(@result, self)
        end
        @result
      end


      class Group
        def initialize(*)
          @validations = Class.new(Reform::Form::ActiveModel::Validations::Validator)
        end

        extend Uber::Delegates
        delegates :@validations, :validates, :validate, :validates_with, :validate_with

        def call(form)
          validator = @validations.new(form)
          success = validator.valid? # run the validations

          Result.new(success, validator.errors.messages)
        end
      end

      # The idea here to mimic Dry.RB's Result API.
      class Result < Hash # FIXME; should this be AMV::Errors?
        def initialize(success, hash)
          super()
          @success = success
          hash.each { |k,v| self[k] = v }
        end

        def success?
          @success
        end

        def failure?
          ! success?
        end

        def messages
          self
        end

        # DISCUSS @FRAN: not sure this is 100% compatible with AMV::Errors?
        def errors
          self
        end

        class Errors < ActiveModel::Errors # when validating
          def failure?
            any?
          end
        end

        class ResultErrors < ::Reform::Contract::Result::Errors # to expose via #errors. i hate it.
          def empty?
            size == 0
          end

          def [](k)
            super || []
          end
        end
      end

      # Validator is the validatable object. On the class level, we define validations,
      # on instance, it exposes #valid?.
      require "delegate"
      class Validator < SimpleDelegator
        # current i18n scope: :activemodel.
        include ActiveModel::Validations

        class << self
          def model_name
            @_active_model_sucks ||= ActiveModel::Name.new(Reform::Form, nil, "Reform::Form")
          end

          def model_name=(name)
            @_active_model_sucks = name
          end

          def validates(*args, &block)
            super(*Declarative::DeepDup.(args), &block)
          end

          # Prevent AM:V from mutating the validator class
          def attr_reader(*)
          end

          def attr_writer(*)
          end
        end

        def initialize(form)
          super(form)
          self.class.model_name = form.model_name
        end

        def method_missing(m, *args, &block)
          __getobj__.send(m, *args, &block) # send all methods to the form, even privates.
        end
      end
    end


  end
end
