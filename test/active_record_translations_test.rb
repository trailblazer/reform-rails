require 'test_helper'
require 'reform/active_record'

class ActiveRecordTranslationsTest < MiniTest::Spec
  class SongForm < Reform::Form
    include Reform::Form::ActiveModel::Validations
    include Reform::Form::ActiveRecord

    property :title
    property :created_at
  end

  before do
    I18n.backend.store_translations(:en,
      activerecord: {
        attributes: {
          'active_record_translations_test/song': {
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
