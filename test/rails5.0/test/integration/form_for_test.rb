require "test_helper"

class SongsControllerTest < ActionDispatch::IntegrationTest
  test 'edit' do
    get edit_song_path(1)
    response.body.must_equal %{<form class="edit_song" id="edit_song_1" action="/songs/1" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="_method" value="patch" />
<input type="text" value="Murder" name="song[title]" id="song_title" />

  <input type=\"text\" name=\"artist[name]\" id=\"artist_name\" />
</form>
}
  end

  test 'update' do
    put song_path(1), params: { song: { title: "", artist_attributes: { name: "" } } }
    response.body.must_equal %{<form class="edit_song" id="edit_song_1" action="/songs/1" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="_method" value="patch" />
<input type="text" value="" name="song[title]" id="song_title" />

  <input type=\"text\" name=\"artist[name]\" id=\"artist_name\" />
</form>
Title can&#39;t be blank
Artist Name can&#39;t be blank
}
  end
end
