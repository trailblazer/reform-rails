ENV["RAILS_ENV"] = "test"

require 'minitest/autorun'

require "rails-app/config/environment"
require 'reform/rails'

require "reform/form/active_model/form_builder_methods"
require "reform/form/active_model"

require "reform/form/active_model/model_validations"
require "reform/form/active_model/validations"

require 'active_record'
class Artist < ActiveRecord::Base
end

class Song < ActiveRecord::Base
  belongs_to :artist
end

class Album < ActiveRecord::Base
  has_many :songs
end

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "#{Dir.pwd}/database.sqlite3"
)

Minitest::Spec.class_eval do
  def self.rails5_0?
    ::ActiveModel::VERSION::MAJOR == 5 and ::ActiveModel::VERSION::MINOR == 0
  end

  def self.rails_greater_4_1?
    (::ActiveModel::VERSION::MAJOR == 4 and ::ActiveModel::VERSION::MINOR == 2) || (::ActiveModel::VERSION::MAJOR >= 5)
  end
end

I18n.load_path << Dir['test/fixtures/locales/*.yml']
I18n.backend.load_translations

class BaseTest < MiniTest::Spec
  class AlbumForm < Reform::Form
    property :title

    property :hit do
      property :title
    end

    collection :songs do
      property :title
    end
  end

  Song   = Struct.new(:title, :length)
  Album  = Struct.new(:title, :hit, :songs, :band)
  Band   = Struct.new(:label)
  Label  = Struct.new(:name)
  Length = Struct.new(:minutes, :seconds)


  let (:hit) { Song.new("Roxanne") }
end
