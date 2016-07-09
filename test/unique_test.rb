require "test_helper"

require "reform/form/validation/unique_validator.rb"
require "reform/form/active_record"

class UniquenessValidatorOnCreateTest < MiniTest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :title
    validates :title, unique: true
  end

  it do
    Song.delete_all

    form = SongForm.new(Song.new)
    form.validate("title" => "How Many Tears").must_equal true
    form.save

    form = SongForm.new(Song.new)
    form.validate("title" => "How Many Tears").must_equal false
    form.errors.to_s.must_equal "{:title=>[\"has already been taken\"]}"
  end
end

class UniquenessValidatorOnCreateCaseInsensitiveTest < MiniTest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :title
    validates :title, unique: { case_sensitive: false }
  end

  it do
    Song.delete_all

    form = SongForm.new(Song.new)
    form.validate("title" => "How Many Tears").must_equal true
    form.save

    form = SongForm.new(Song.new)
    form.validate("title" => "how many tears").must_equal false
    form.errors.to_s.must_equal "{:title=>[\"has already been taken\"]}"
  end

  it do
    Song.delete_all

    form = SongForm.new(Song.new)
    form.validate({}).must_equal true
  end
end

class UniquenessValidatorOnCreateCaseSensitiveTest < MiniTest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :title
    validates :title, unique: { case_sensitive: true }
  end

  it do
    Song.delete_all

    form = SongForm.new(Song.new)
    form.validate("title" => "How Many Tears").must_equal true
    form.save

    form = SongForm.new(Song.new)
    form.validate("title" => "how many tears").must_equal true
  end
end

class UniquenessValidatorOnUpdateTest < MiniTest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :title
    validates :title, unique: true
  end

  it do
    Song.delete_all
    @song = Song.create(title: "How Many Tears")

    form = SongForm.new(@song)
    form.validate("title" => "How Many Tears").must_equal true
    form.save

    form = SongForm.new(@song)
    form.validate("title" => "How Many Tears").must_equal true
  end
end


class UniqueWithCompositionTest < MiniTest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    include Composition

    property :title, on: :song
    validates :title, unique: true
  end

  it do
    Song.delete_all

    form = SongForm.new(song: Song.new)
    form.validate("title" => "How Many Tears").must_equal true
    form.save
  end
end


class UniqueValidatorWithScopeTest < MiniTest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :album_id
    property :title
    validates :title, unique: { scope: :album_id }
  end

  it do
    Song.delete_all

    album = Album.new
    album.save

    form = SongForm.new(Song.new)
    form.validate(album_id: album.id, title: 'How Many Tears').must_equal true
    form.save

    form = SongForm.new(Song.new)
    form.validate(album_id: album.id, title: 'How Many Tears').must_equal false
    form.errors.to_s.must_equal "{:title=>[\"has already been taken\"]}"

    album = Album.new
    album.save

    form = SongForm.new(Song.new)
    form.validate(album_id: album.id, title: 'How Many Tears').must_equal true
  end
end

class UniqueValidatorWithScopeAndCaseInsensitiveTest < MiniTest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :album_id
    property :title
    validates :title, unique: { scope: :album_id, case_sensitive: false }
  end

  it do
    Song.delete_all

    album = Album.new
    album.save

    form = SongForm.new(Song.new)
    form.validate(album_id: album.id, title: 'How Many Tears').must_equal true
    form.save

    form = SongForm.new(Song.new)
    form.validate(album_id: album.id, title: 'how many tears').must_equal false
    form.errors.to_s.must_equal "{:title=>[\"has already been taken\"]}"

    album = Album.new
    album.save

    form = SongForm.new(Song.new)
    form.validate(album_id: album.id, title: 'how many tears').must_equal true
  end
end

class UniqueValidatorWithScopeArrayTest < MiniTest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :album_id
    property :artist_id
    property :title
    validates :title, unique: { scope: [:album_id, :artist_id] }
  end

  it do
    Song.delete_all

    album1 = Album.new
    album1.save

    artist1 = Artist.new
    artist1.save

    form = SongForm.new(Song.new)
    form.validate(album_id: album1.id, artist_id: artist1.id, title: 'How Many Tears').must_equal true
    form.save

    form = SongForm.new(Song.new)
    form.validate(album_id: album1.id, artist_id: artist1.id, title: 'How Many Tears').must_equal false
    form.errors.to_s.must_equal "{:title=>[\"has already been taken\"]}"

    album2 = Album.new
    album2.save

    form = SongForm.new(Song.new)
    form.validate(album_id: album2.id, artist_id: artist1.id, title: 'How Many Tears').must_equal true

    artist2 = Artist.new
    artist2.save

    form = SongForm.new(Song.new)
    form.validate(album_id: album1.id, artist_id: artist2.id, title: 'How Many Tears').must_equal true
  end
end
