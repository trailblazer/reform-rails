require "test_helper"

class ModuleInclusionTest < MiniTest::Spec
  module BandPropertyForm
    include Reform::Form::Module

    property :artist
    property :band do
      property :title

      validates :title, presence: true
    end
    validates :band, presence: true

    module InstanceMethods
      def artist=(new_value)
        errors.add(:artist, "this need to be filled") if new_value.nil?
        super(new_value)
      end
    end
  end

  class SongForm < Reform::Form
    include BandPropertyForm
  end

  let(:song) { OpenStruct.new(band: OpenStruct.new(title: "Time Again"), artist: "Ketama") }

  # nested form from module is present and creates accessor.
  it { SongForm.new(song).band.title.must_equal "Time Again" }
  it { SongForm.new(song).artist.must_equal "Ketama" }

  # validators get inherited.
  it do
    form = SongForm.new(OpenStruct.new)
    form.validate(artist: nil)
    form.errors.messages.must_equal(artist: ["this needs to be filled"], band: ["must be filled"])
  end
end
