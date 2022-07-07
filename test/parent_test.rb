require 'test_helper'
require 'disposable/twin/parent'

class ParentTest < BaseTest

  class AlbumForm < Reform::Form

    feature Disposable::Twin::Parent

    property :band
    validates :band, presence: true

    collection :songs, virtual: true, default: [], populator: :populate_songs! do
      property :name
      validate :unique_name

      def unique_name
        if name == parent.band
          errors.add(:name, "Song name shouldn't be the same as #{parent.band}")
        end
      end
    end

    def populate_songs!(fragment:, **)
      existed_song = songs.find { |song| song.name == fragment[:name] }
      return existed_song if existed_song
      songs.append(OpenStruct.new(name: fragment[:name]))
    end

  end

  let (:form) {
    AlbumForm.new(OpenStruct.new(
      :band => "Killer Queen"
    ))
  }

  it "allows nested collection validation messages to be shown" do
    form.validate(songs: [{ name: "Killer Queen" }])
    _(form.errors.full_messages).must_equal(["Name Song name shouldn't be the same as Killer Queen"])
  end

end
