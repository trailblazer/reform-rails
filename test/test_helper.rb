$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'reform/rails'

require 'minitest/autorun'

require "rails-app/config/environment"

require "reform/form/active_model/validations"
Reform::Contract.class_eval do
  feature Reform::Form::ActiveModel::Validations
end
# FIXME!
Reform::Form.class_eval do
  feature Reform::Form::ActiveModel::Validations
end

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
  def self.rails4_2?
    ::ActiveModel::VERSION::MAJOR == 4 and ::ActiveModel::VERSION::MINOR == 2
  end

  def self.rails4_0?
    ::ActiveModel::VERSION::MAJOR == 4 and ::ActiveModel::VERSION::MINOR == 0
  end

  def self.rails3_2?
    ::ActiveModel::VERSION::MAJOR == 3 and ::ActiveModel::VERSION::MINOR == 2
  end
end

I18n.load_path << Dir['test/dummy/config/locales/*.yml']
I18n.backend.load_translations
