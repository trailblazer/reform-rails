require "test_helper"

class ActiveModelValidationTest < Minitest::Spec
  Session = Struct.new(:username, :email, :password, :confirm_password)
  Album = Struct.new(:name, :songs, :artist)
  Artist = Struct.new(:name)

  class SessionForm < Reform::Form
    include Reform::Form::ActiveModel::Validations

    property :username
    property :email
    property :password
    property :confirm_password

    validation name: :default do
      validates :username, presence: true
      validates :email, presence: true
    end

    validation name: :email, if: :default do
      # validate :email_ok? # FIXME: implement that.
      validates :email, length: {is: 3}
    end

    validation name: :nested, if: :default do
      validates :password, presence: true, length: {is: 1}
    end

    validation name: :confirm, if: :default, after: :email do
      validates :confirm_password, length: {is: 2}
    end
  end

  let (:form) { SessionForm.new(Session.new) }

  # valid.
  it do
    _(form.validate({username: "Helloween", email: "yep", password: "9", confirm_password:"dd"})).must_equal true
    _(form.errors.messages.inspect).must_equal "{}"
  end

  # invalid.
  it do
    _(form.validate({})).must_equal false
    _(form.errors.messages.inspect).must_equal "{:username=>[\"can't be blank\"], :email=>[\"can't be blank\"]}"
    _(form.errors[:username]).must_equal ["can't be blank"]
    _(form.errors['username']).must_equal ["can't be blank"]
  end

  # partially invalid.
  # 2nd group fails.
  let (:character) { self.class.rails_greater_4_1? ? :character : :characters}
  it do
    _(form.validate(username: "Helloween", email: "yo")).must_equal false
    _(form.errors.messages.inspect).must_equal "{:email=>[\"is the wrong length (should be 3 characters)\"], :confirm_password=>[\"is the wrong length (should be 2 characters)\"], :password=>[\"can't be blank\", \"is the wrong length (should be 1 #{character})\"]}"
  end
  # 3rd group fails.
  it do
    _(form.validate(username: "Helloween", email: "yo!")).must_equal false
    _(form.errors.messages.inspect).must_equal"{:confirm_password=>[\"is the wrong length (should be 2 characters)\"], :password=>[\"can't be blank\", \"is the wrong length (should be 1 #{character})\"]}"
  end
  # 4th group with after: fails.
  it do
    _(form.validate(username: "Helloween", email: "yo!", password: "1", confirm_password: "9")).must_equal false
    _(form.errors.messages.inspect).must_equal "{:confirm_password=>[\"is the wrong length (should be 2 characters)\"]}"
  end


  describe "implicit :default group" do
    # implicit :default group.
    class LoginForm < Reform::Form
      include Reform::Form::ActiveModel::Validations


      property :username
      property :email
      property :password
      property :confirm_password

      validates :username, presence: true
      validates :email, presence: true
      validates :password, presence: true

      validation name: :after_default, if: :default do
        validates :confirm_password, presence: true
      end
    end

    let (:form) { LoginForm.new(Session.new) }

    # valid.
    it do
      _(form.validate({username: "Helloween", email: "yep", password: "9", confirm_password: 9})).must_equal true
      _(form.errors.messages.inspect).must_equal "{}"
    end

    # invalid.
    it do
      _(form.validate({password: 9})).must_equal false
      _(form.errors.messages.inspect).must_equal "{:username=>[\"can't be blank\"], :email=>[\"can't be blank\"]}"
    end

    # partially invalid.
    # 2nd group fails.
    it do
      _(form.validate(password: 9)).must_equal false
      _(form.errors.messages.inspect).must_equal "{:username=>[\"can't be blank\"], :email=>[\"can't be blank\"]}"
    end
  end


  # describe "overwriting a group" do
  #   class OverwritingForm < Reform::Form
  #     include Reform::Form::ActiveModel::Validations

  #     property :username
  #     property :email

  #     validation :email do
  #       validates :email, presence: true # is not considered, but overwritten.
  #     end

  #     validation :email do # overwrites the above.
  #       validates :username, presence: true
  #     end
  #   end

  #   let (:form) { OverwritingForm.new(Session.new) }

  #   # valid.
  #   it do
  #     _(form.validate({username: "Helloween"})).must_equal true
  #   end

  #   # invalid.
  #   it do
  #     _(form.validate({})).must_equal false
  #     _(form.errors.messages.inspect).must_equal "{:username=>[\"username can't be blank\"]}"
  #   end
  # end


  describe "inherit: true in same group" do
    class InheritSameGroupForm < Reform::Form
      include Reform::Form::ActiveModel::Validations

      property :username
      property :email

      validation name: :email do
        validates :email, presence: true
      end

      validation name: :email, inherit: true do # extends the above.
        validates :username, presence: true
      end
    end

    let (:form) { InheritSameGroupForm.new(Session.new) }

    # valid.
    it do
      _(form.validate({username: "Helloween", email: 9})).must_equal true
    end

    # invalid.
    it do
      _(form.validate({})).must_equal false
      _(form.errors.messages.inspect).must_equal "{:email=>[\"can't be blank\"], :username=>[\"can't be blank\"]}"

      if self.class.rails5?
        _(form.errors.details.inspect).must_equal "{:email=>[{:error=>:blank}], :username=>[{:error=>:blank}]}"
      end
    end
  end


  describe "if: with lambda" do
    class IfWithLambdaForm < Reform::Form
      include Reform::Form::ActiveModel::Validations

      property :username
      property :email
      property :password

      validation name: :email do
        validates :email, presence: true
      end

      # run this is :email group is true.
      validation name: :after_email, if: lambda { |results| results[:email].success? } do # extends the above.
        validates :username, presence: true
      end

      # block gets evaled in form instance context.
      validation name: :password, if: lambda { |results| email == "john@trb.org" } do
        validates :password, presence: true
      end
    end

    let (:form) { IfWithLambdaForm.new(Session.new) }

    # valid.
    it do
      _(form.validate({username: "Strung Out", email: 9})).must_equal true
    end

    # invalid.
    it do
      _(form.validate({email: 9})).must_equal false
      _(form.errors.messages.inspect).must_equal "{:username=>[\"can't be blank\"]}"
      if self.class.rails5?
        _(form.errors.details.inspect).must_equal "{:username=>[{:error=>:blank}]}"
      end

    end
  end


# TODO: describe "multiple errors for property" do

  describe "::validate" do
    class ValidateForm < Reform::Form
      include Reform::Form::ActiveModel::Validations

      property :email
      property :username

      validates :username, presence: true
      validate :username_ok?#, context: :entity
      validate :username_yo?

      validates :email, presence: true
      validate :email_present?

      # this breaks as at the point of execution 'errors' doesn't exist...
      # Guessing it's unexceptable to introduce our own API....
      # add_error(:key, val)
      def username_ok?#(value)
        errors.add(:username, "not ok") if username == "yo"
      end

      # depends on username_ok? result. this tests the same errors is used.
      def username_yo?
        errors.add(:username, "must be yo") if errors[:username].any?
      end

      def email_present?
        errors.add(:email, "fill it out!") if errors[:email].any?
      end
    end

    let (:form) { ValidateForm.new(Session.new) }

    # invalid.
    it "is invalid" do
      _(form.validate({username: "yo", email: nil})).must_equal false
      _(form.errors.messages).must_equal({:email=>["can't be blank", "fill it out!"], :username=>["not ok", "must be yo"]})
      if self.class.rails5?
        _(form.errors.details.inspect).must_equal "{:username=>[{:error=>\"not ok\"}, {:error=>\"must be yo\"}], :email=>[{:error=>:blank}, {:error=>\"fill it out!\"}]}"
      end
    end

    # valid.
    it "is valid" do
      _(form.validate({ username: "not yo", email: "bla" })).must_equal true
      if self.class.rails_greater_6_0?
        _(form.errors.messages).must_equal({})
      else
        _(form.errors.messages).must_equal({:username=>[], :email=>[]})
      end
      if self.class.rails5?
        _(form.errors.details.inspect).must_equal "{}"
      end
      _(form.errors.empty?).must_equal true
    end

    it 'able to add errors' do
      _(form.validate(username: "yo", email: nil)).must_equal false
      _(form.errors.messages).must_equal(email: ["can't be blank", "fill it out!"], username: ["not ok", "must be yo"])
      _(form.errors.details).must_equal(username: [{error: "not ok"}, {error: "must be yo"}], email: [{error: :blank}, {error: "fill it out!"}])
      # add a new custom error
      form.errors.add(:policy, "error_text")
      _(form.errors.messages).must_equal(email: ["can't be blank", "fill it out!"], username: ["not ok", "must be yo"], policy: ["error_text"])
      _(form.errors.details).must_equal(
        username: [{error: "not ok"}, {error: "must be yo"}],
        email: [{error: :blank}, {error: "fill it out!"}],
        policy: [error: "error_text"]
      )
      # does not duplicate errors
      form.errors.add(:email, "fill it out!")
      _(form.errors.messages).must_equal(email: ["can't be blank", "fill it out!"], username: ["not ok", "must be yo"], policy: ["error_text"])
      _(form.errors.details).must_equal(
        username: [{error: "not ok"}, {error: "must be yo"}],
        email: [{error: :blank}, {error: "fill it out!"}, {error: "fill it out!"}],
        policy: [error: "error_text"]
      )
      # merge existing errors
      form.errors.add(:policy, "another error")
      _(form.errors.messages).must_equal(email: ["can't be blank", "fill it out!"], username: ["not ok", "must be yo"], policy: ["error_text", "another error"])
      _(form.errors.details).must_equal(
        username: [{error: "not ok"}, {error: "must be yo"}],
        email: [{error: :blank}, {error: "fill it out!"}, {error: "fill it out!"}],
        policy: [{error: "error_text"}, {error: "another error"}]
      )
      # keep added errors after valid?
      form.valid?
      _(form.errors.details).must_equal(
        username: [{error: "not ok"}, {error: "must be yo"}],
        email: [{error: :blank}, {error: "fill it out!"}],
        policy: [{error: "error_text"}, {error: "another error"}]
      )
      _(form.errors.added?(:policy, "error_text")).must_equal true
      _(form.errors.added?(:policy, "another error")).must_equal true
      _(form.errors.messages).must_equal(email: ["can't be blank", "fill it out!"], username: ["not ok", "must be yo"], policy: ["error_text", "another error"])
      # keep added errors after validate
      _(form.validate(username: "username", email: "email@email.com")).must_equal false
      if self.class.rails_greater_6_0?
        _(form.errors.messages).must_equal(policy: ["error_text", "another error"])
      else
        _(form.errors.messages).must_equal(policy: ["error_text", "another error"], username: [], email: [])
      end
      _(form.errors.added?(:policy, "error_text")).must_equal true
      _(form.errors.added?(:policy, "another error")).must_equal true
      _(form.errors.details).must_equal(
        policy: [{error: "error_text"}, {error: "another error"}]
      )

      form.errors.add(:email, :less_than_or_equal_to, count: 2)
      _(form.errors.messages[:email]).must_equal(["must be less than or equal to 2"])
    end
  end

  describe "validates: :acceptance" do
    class AcceptanceForm < Reform::Form
      property :accept, virtual: true, validates: { acceptance: true }
    end

    it do
      skip('fails in rails 5') if self.class.rails5?
      _(AcceptanceForm.new(nil).validate(accept: "0")).must_equal false
    end

    it do
      skip('fails in rails 5') if self.class.rails5?
      _(AcceptanceForm.new(nil).validate(accept: "1")).must_equal true
    end
  end

  describe "validates_each" do
   class ValidateEachForm < Reform::Form
     include Reform::Form::ActiveModel::Validations

     property :songs

     validation do
       validates_each :songs do |record, attr, value|
         record.errors.add attr, "is invalid" unless ['red','green','blue'].include?(value)
       end
     end
   end

   class ValidateEachForm2 < Reform::Form
     include Reform::Form::ActiveModel::Validations

     property :songs

     validates_each :songs do |record, attr, value|
       record.errors.add attr, "is invalid" unless ['red','green','blue'].include?(value)
     end
   end

   it { _(ValidateEachForm.new(Album.new).validate(songs: "orange")).must_equal false }
   it { _(ValidateEachForm.new(Album.new).validate(songs: "red")).must_equal true }

   it { _(ValidateEachForm2.new(Album.new).validate(songs: "orange")).must_equal false }
   it { _(ValidateEachForm2.new(Album.new).validate(songs: "red")).must_equal true }
 end
end

# Regression
# Addresses a bug: https://github.com/trailblazer/reform-rails/issues/103
class ActiveModelValidationWithIfTest < Minitest::Spec
  Session = Struct.new(:id)
  # Album = Struct.new(:name, :songs, :artist)
  # Artist = Struct.new(:name)

  class SessionForm < Reform::Form
    include Reform::Form::ActiveModel::Validations

    property :id, virtual: true

    # validates :id, presence: true, if: -> { raise id.inspect }
  end

  let (:form) { SessionForm.new(Session.new(2)) }

  # valid.
  it do
    assert_equal form.id, nil
  end
end
