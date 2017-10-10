class SongsController < ApplicationController
  layout false

  def new
    song  = Song.create(title: "Murder", artist: Artist.new(name: "Selecter"))
    @form = SongForm.new(song)
  end

  def create
    song  = Song.create(title: "", artist: Artist.new(name: ""))
    @form = SongForm.new(song)

    @form.validate(params)

    render :new
  end

  def edit
    song  = Song.create(title: "Murder", artist: Artist.new(name: "Selecter"))
    @form = SongForm.new(song)
  end

  def update
    song  = Song.create(title: "", artist: Artist.new(name: ""))
    @form = SongForm.new(song)

    # raise params.inspect
    @form.validate(params)

    render :edit
  end
end
