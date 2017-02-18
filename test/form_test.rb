require "test_helper"

class FormTest < Minitest::Spec
  # combined property/validates syntax.
  class SongForm < Reform::Form
    property :composer
    property :title, validates: {presence: true}
    properties :genre, :band, validates: {presence: true}
  end
  it do
    form = SongForm.new(OpenStruct.new)
    form.validate({})
    form.errors.messages.must_equal({:title=>["can't be blank"], :genre=>["can't be blank"], :band=>["can't be blank"]})
  end
end
