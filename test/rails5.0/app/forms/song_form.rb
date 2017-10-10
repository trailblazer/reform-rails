require 'reform/form/coercion'
class SongForm < Reform::Form
  include Coercion

  model Song

  property :title
  # this shouldn't be required, # also tests simpleforms autoguess of type
  property :release_date, type: Types::Date

  validates :title, presence: true

  property :artist do
    property :name
    validates :name, presence: true
  end
end