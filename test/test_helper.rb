ENV["RAILS_ENV"] = "test"

require 'minitest/autorun'

# Load the rails application
require "active_model/railtie"

Bundler.require

module Dummy
  class Application < Rails::Application
    config.eager_load = false
    config.active_support.deprecation = :stderr
  end
end

# Initialize the rails application
Dummy::Application.initialize!

require 'active_record'
class Artist < ActiveRecord::Base
end

class Song < ActiveRecord::Base
  belongs_to :artist
end

class Album < ActiveRecord::Base
  has_many :songs
end

ActiveRecord::Base.establish_connection :adapter => 'sqlite3',
                                        :database => ':memory:'
ActiveRecord::Schema.verbose = false
load "#{File.dirname(__FILE__)}/support/schema.rb"

Minitest::Spec.class_eval do
  def self.rails5?
    ::ActiveModel::VERSION::MAJOR == 5
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
