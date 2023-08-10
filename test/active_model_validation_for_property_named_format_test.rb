require "test_helper"

class AMValidationWithFormatTest < Minitest::Spec
  class SongForm < Reform::Form
    include Reform::Form::ActiveModel

    property :format
    validates :format, presence: true
  end

  Song = Struct.new(:format)

  it do
    _(SongForm.new(Song.new).validate({ format: 12 })).must_equal true
  end
end
