require "test_helper"

class AMValidationWithFormatTest < MiniTest::Spec
  class SongForm < Reform::Form
    include Reform::Form::ActiveModel

    property :format
    validates :format, presence: true
  end

  Song = Struct.new(:format)

  it do
    skip("FIXME!! current code only works on ruby 2.0.0 dunnoo why...")
    SongForm.new(Song.new).validate({ format: 12 }).must_equal true
  end
end