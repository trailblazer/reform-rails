class SongsController < ApplicationController
  layout false

  class EditForm < Reform::Form
    model Song

    property :title
    validates :title, presence: true

    property :artist do
      property :name
      validates :name, presence: true
    end
  end

  def new
    song  = Song.create(title: "Murder", artist: Artist.new(name: "Selecter"))
    @form = EditForm.new(song)
  end

  def create
    song  = Song.create(title: "", artist: Artist.new(name: ""))
    @form = EditForm.new(song)

    # raise params.inspect
    @form.validate(params)

    render :new
  end

  def edit
    song  = Song.create(title: "Murder", artist: Artist.new(name: "Selecter"))
    @form = EditForm.new(song)
  end

  def update
    song  = Song.create(title: "", artist: Artist.new(name: ""))
    @form = EditForm.new(song)

    # raise params.inspect
    @form.validate(params)

    render :edit
  end
end
