require "test_helper"

if defined?(ActiveModel::ForbiddenAttributesProtection)
  # *actionpack* is not a hard gem dependency (just a development dependency); it's just a
  # convenient reference implementation and the one most Rails users will probably be using. But we
  # could have used a custom ProtectedParams or whatever like they did in:
  # - https://github.com/rails/rails/blob/master/activemodel/test/cases/forbidden_attributes_protection_test.rb
  # - https://github.com/rails/rails/blob/master/activerecord/test/cases/forbidden_attributes_protection_test.rb
  require "action_controller/metal/strong_parameters"

  class StrongParametersTest < Minitest::Spec
    if ActiveRecord.gem_version >= Gem::Version.new("5.0")
      class User
        include ActiveModel::Model
        attr_accessor :name
        attr_accessor :is_superuser
      end
    else
      class User < ActiveRecord::Base
      end
    end
    class UserForm < Reform::Form
      property :name
      property :is_superuser
    end

    describe "when params is an object that responds to `permitted?`" do
      let(:record) { User.new }
      let(:form)   { UserForm.new(record) }

      describe "when all params are permitted (safe)" do
        let(:params) { ActionController::Parameters.new({"name"=>""}).permit(:name) }

        it { assert params.permitted? }
        it 'ActiveModel and Reform' do
          # No errors
          record.assign_attributes(params)
          form.validate           (params)
        end
      end

      describe "when params are not permitted yet (unsafe)" do
        let(:params) { ActionController::Parameters.new({name: 'name', is_superuser: true}) }

        it { refute params.permitted? }
        it 'ActiveModel' do
          assert_raises ActiveModel::ForbiddenAttributesError do
            record.assign_attributes(params)
            assert record.is_superuser
          end
        end
        it 'Reform' do
          assert_raises ActiveModel::ForbiddenAttributesError do
            form.validate(params)
          end
          # *Without* sanitize_for_mass_assignment, this would set is_superuser
          form.sync
          assert_nil record.is_superuser
        end
      end

      describe "when some params are permitted and others are not (safe)" do
        let(:params) { ActionController::Parameters.new({name: 'name', is_superuser: true}).permit(:name) }

        it { assert params.permitted? }
        # No trace of the unpermitted params remains (safe)
        it { params.                     to_h.must_equal({"name"=>"name"}) }
        it { params.enum_for(:each_pair).to_h.must_equal({"name"=>"name"}) }
        it 'ActiveModel' do
          record.assign_attributes(params)
          record.name.must_equal 'name'
          assert_nil record.is_superuser
        end
        it 'Reform' do
          form.validate(params)
          form.sync
          record.name.must_equal 'name'
          assert_nil record.is_superuser
        end
      end

      describe "when StrongParameters is 'turned off' (all parameters permitted by top-level default) (unsafe)" do
        before { ActionController::Parameters.permit_all_parameters = true }
        after  { ActionController::Parameters.permit_all_parameters = false }
        let(:params) { ActionController::Parameters.new({name: 'name', is_superuser: true}) }

        it { assert params.permitted? }
        it { params.                     to_h.must_equal({"name"=>"name", "is_superuser"=>true}) }
        it { params.enum_for(:each_pair).to_h.must_equal({"name"=>"name", "is_superuser"=>true}) }
        it 'ActiveModel' do
          record.assign_attributes(params)
          assert record.is_superuser
        end
        it 'Reform' do
          form.validate(params)
          form.sync
          assert record.is_superuser
        end
      end
    end
  end
end
