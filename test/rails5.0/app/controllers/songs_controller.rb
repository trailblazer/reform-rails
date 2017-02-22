class SongsController < ApplicationController

  class EditForm < Reform::Form
    property :title
  end

  def edit
    song = Song.create(title: "Murder")
  end
end
