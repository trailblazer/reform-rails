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
    _(form.errors.messages).must_equal({:title=>["can't be blank"], :genre=>["can't be blank"], :band=>["can't be blank"]})
  end

  Album = Struct.new(:hit)
  Song = Struct.new(:length)
  class PopulatedAlbumForm < Reform::Form
    property :hit, populate_if_empty: Song do
      property :length
      validates :length, numericality: { greater_than: 55 }
    end
  end
  it do
    form = PopulatedAlbumForm.new(Album.new)
    _(form.validate({ :hit => { :length => "54" }})).must_equal(false)
    _(form.errors.messages).must_equal({ :"hit.length" => ["must be greater than 55"] })
    _(form.validate({ :hit => { :length => "57" }})).must_equal(true)
    _(form.errors.messages).must_equal({})
  end
end
