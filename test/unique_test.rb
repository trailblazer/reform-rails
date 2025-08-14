require "test_helper"

require "reform/form/orm"
require "reform/form/validation/unique_validator.rb"
require "reform/form/active_record"

class UniquenessValidatorOnCreateTest < Minitest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :title
    validates :title, unique: true
  end

  it do
    Song.delete_all

    form = SongForm.new(Song.new)
    _(form.validate("title" => "How Many Tears")).must_equal true
    form.save

    form = SongForm.new(Song.new)
    _(form.validate("title" => "How Many Tears")).must_equal false
    _(form.errors.messages).must_equal ({:title=>["has already been taken"]})
  end
end

class UniquenessValidatorOnCreateCaseInsensitiveTest < Minitest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :title
    validates :title, unique: { case_sensitive: false }
  end

  it do
    Song.delete_all

    form = SongForm.new(Song.new)
    _(form.validate("title" => "How Many Tears")).must_equal true
    form.save

    form = SongForm.new(Song.new)
    _(form.validate("title" => "how many tears")).must_equal false
    _(form.errors.to_s).must_equal "{:title=>[\"has already been taken\"]}"
  end

  it do
    Song.delete_all

    form = SongForm.new(Song.new)
    _(form.validate({})).must_equal true
  end
end

class UniquenessValidatorOnUpdateTest < Minitest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :title
    validates :title, unique: true
  end

  it do
    Song.delete_all
    @song = Song.create(title: "How Many Tears")

    form = SongForm.new(@song)
    _(form.validate("title" => "How Many Tears")).must_equal true
    form.save

    form = SongForm.new(@song)
    _(form.validate("title" => "How Many Tears")).must_equal true
  end
end

class UniquenessValidatorOnUpdateWithDuplicateTest < Minitest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :title
    validates :title, unique: true
  end

  it do
    Song.delete_all

    song1 = Song.create(title: "How Many Tears")
    song2 = Song.create(title: "How Many Tears 2")

    form = SongForm.new(song1)
    _(form.validate("title" => "How Many Tears 2")).must_equal false
    _(form.errors.to_s).must_equal "{:title=>[\"has already been taken\"]}"
  end
end

class UniquenessValidatorWithFromPropertyTest < Minitest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :name, from: :title
    validates :name, unique: true
  end

  it do
    Song.delete_all

    form = SongForm.new(Song.new)
    _(form.validate("name" => "How Many Tears")).must_equal true
    form.save

    form = SongForm.new(Song.new)
    _(form.validate("name" => "How Many Tears")).must_equal false
    _(form.errors.to_s).must_equal "{:name=>[\"has already been taken\"]}"
  end
end

class UniqueWithCompositionTest < Minitest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    include Composition

    property :title, on: :song
    validates :title, unique: true
  end

  it do
    Song.delete_all

    form = SongForm.new(song: Song.new)
    _(form.validate("title" => "How Many Tears")).must_equal true
    form.save
  end
end


class UniqueValidatorWithScopeTest < Minitest::Spec
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
    _(form.validate(album_id: album.id, title: 'How Many Tears')).must_equal true
    form.save

    form = SongForm.new(Song.new)
    _(form.validate(album_id: album.id, title: 'How Many Tears')).must_equal false
    _(form.errors.messages).must_equal({:title=>["has already been taken"]})

    album = Album.new
    album.save

    form = SongForm.new(Song.new)
    _(form.validate(album_id: album.id, title: 'How Many Tears')).must_equal true
  end
end

class UniqueValidatorWithScopeAndCaseInsensitiveTest < Minitest::Spec
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
    _(form.validate(album_id: album.id, title: 'How Many Tears')).must_equal true
    form.save

    form = SongForm.new(Song.new)
    _(form.validate(album_id: album.id, title: 'how many tears')).must_equal false
    _(form.errors.to_s).must_equal "{:title=>[\"has already been taken\"]}"

    album = Album.new
    album.save

    form = SongForm.new(Song.new)
    _(form.validate(album_id: album.id, title: 'how many tears')).must_equal true
  end
end

class UniqueValidatorWithScopeArrayTest < Minitest::Spec
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
    _(form.validate(album_id: album1.id, artist_id: artist1.id, title: 'How Many Tears')).must_equal true
    form.save

    form = SongForm.new(Song.new)
    _(form.validate(album_id: album1.id, artist_id: artist1.id, title: 'How Many Tears')).must_equal false
    _(form.errors.messages).must_equal({:title=>["has already been taken"]})

    album2 = Album.new
    album2.save

    form = SongForm.new(Song.new)
    _(form.validate(album_id: album2.id, artist_id: artist1.id, title: 'How Many Tears')).must_equal true

    artist2 = Artist.new
    artist2.save

    form = SongForm.new(Song.new)
    _(form.validate(album_id: album1.id, artist_id: artist2.id, title: 'How Many Tears')).must_equal true
  end
end

class UniqueValidatorWithConditions < Minitest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :title
    validates :title, unique: { conditions: -> { where(archived_at: nil) } }
  end

  it do
    Song.delete_all

    form = SongForm.new(Song.new)
    _(form.validate(title: 'How Many Tears')).must_equal true
    form.save

    form = SongForm.new(Song.new)
    _(form.validate(title: 'How Many Tears')).must_equal false
    _(form.errors.messages).must_equal({:title=>["has already been taken"]})

    song = Song.last
    song.update!(archived_at: Time.now)

    form = SongForm.new(Song.new)
    _(form.validate(title: 'How Many Tears')).must_equal true
    form.save
  end
end

class UniqueValidatorWithConditionsWithRecord < Minitest::Spec
  class SongForm < Reform::Form
    include ActiveRecord
    property :title
    property :release_date
    validates :title, unique: {
      conditions: ->(form) {
        published_at = form.release_date
        where(release_date: published_at.beginning_of_month..published_at.end_of_month)
      }
    }
  end

  it do
    Song.delete_all

    today = Date.today
    form = SongForm.new(Song.new)
    _(form.validate(title: 'How Many Tears', release_date: today)).must_equal true
    form.save

    form = SongForm.new(Song.new)
    _(form.validate(title: 'How Many Tears', release_date: today)).must_equal false
    _(form.errors.messages).must_equal({:title=>["has already been taken"]})

    form = SongForm.new(Song.new)
    _(form.validate(title: 'How Many Tears', release_date: today.next_month)).must_equal true
    form.save
  end
end
