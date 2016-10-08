require 'test_helper'

class ActiveModelTranslationsTest < MiniTest::Spec
  class SongForm < Reform::Form
    property :title
    property :created_at
  end

  before do
    I18n.backend.store_translations(:en,
      activemodel: {
        attributes: {
          'active_model_translations_test/song': {
            title: 'Song title',
          }
        }
      }
    )
  end

  it 'translate attribute with I18n' do
    SongForm.human_attribute_name(:title).must_equal 'Song title'
  end

  it 'translate attribute without I18n' do
    SongForm.human_attribute_name(:created_at).must_equal 'Created at'
  end
end
