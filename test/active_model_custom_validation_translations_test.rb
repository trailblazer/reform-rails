require 'test_helper'

class ActiveModelCustomValidationTranslationsTest < Minitest::Spec
  module SongForm
    class WithBlock < Reform::Form
      model :song
      property :title

      validate do
        errors.add :title, :blank
        errors.add :title, :custom_error_message
      end
    end

    class WithLambda < Reform::Form
      model :song
      property :title

      validate ->{ errors.add :title, :blank
                   errors.add :title, :custom_error_message }
    end

    class WithMethod < Reform::Form
      model :song
      property :title

      validate :custom_validation_method
      def custom_validation_method
        errors.add :title, :blank
        errors.add :title, :custom_error_message
      end
    end
  end
  
  class AlbumForm < Reform::Form
    model :album    
    property :title

    validate do
      errors.add :title, :too_short, count: 15
    end

    property :artist, :populate_if_empty => Artist do
      property :name

      validate do
        errors.add :name, :blank
      end
    end

    collection :songs, :populate_if_empty => Song do
      property :title

      validate do
        errors.add :title, :blank
      end
    end
  end

  describe 'when using a default translation' do
    it 'translates the error message when custom validation is used with block' do
      form = SongForm::WithBlock.new(Song.new)
      form.validate({})
      _(form.errors[:title]).must_include "can't be blank"
    end

    it 'translates the error message when custom validation is used with lambda' do
      form = SongForm::WithLambda.new(Song.new)
      form.validate({})
      _(form.errors[:title]).must_include "can't be blank"
    end

    it 'translates the error message when custom validation is used with method' do
      form = SongForm::WithMethod.new(Song.new)
      form.validate({})
      _(form.errors[:title]).must_include "can't be blank"
    end
  end

  describe 'when using a custom translation' do
    it 'translates the error message when custom validation is used with block' do
      form = SongForm::WithBlock.new(Song.new)
      form.validate({})
      _(form.errors[:title]).must_include "Custom Error Message"
    end

    it 'translates the error message when custom validation is used with lambda' do
      form = SongForm::WithLambda.new(Song.new)
      form.validate({})
      _(form.errors[:title]).must_include "Custom Error Message"
    end

    it 'translates the error message when custom validation is used with method' do
      form = SongForm::WithMethod.new(Song.new)
      form.validate({})
      _(form.errors[:title]).must_include "Custom Error Message"
    end
  end

  describe 'when calling full_messages' do
    it 'translates the field name' do
      form = SongForm::WithBlock.new(Song.new)
      form.validate({})
      _(form.errors.full_messages).must_include "Custom Song Title can't be blank"
    end

    describe 'when using nested_model_attributes' do
      it 'translates the nested model attributes name' do
        album = Album.create(title: 'Greatest Hits')
        form = AlbumForm.new(album, artist: Artist.new, songs: [Song.new])
        form.validate({})        
        _(form.errors.full_messages).must_include "Custom Album Title is too short (minimum is 15 characters)"
        _(form.errors.full_messages).must_include "Custom Song Title can't be blank"
        _(form.errors.full_messages).must_include "Custom Artist Name can't be blank"
      end
    end
  end
end
