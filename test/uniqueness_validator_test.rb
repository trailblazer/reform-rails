require "test_helper"

class FormWithLeakyUniquenessValidation < Reform::Form
  property :email
  validates :email, uniqueness: true
end