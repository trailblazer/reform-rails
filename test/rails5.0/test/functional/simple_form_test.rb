require "test_helper"

class SongsSimpleFormControllerTest < ActionDispatch::IntegrationTest
  # tests SongsController

  test "new" do
    get new_song_url
    assert_response :success
    skip("FIXME!! Simpleform can't workout type from dry-types")

    response.parsed_body.must_equal %{<form novalidate=\"novalidate\" class="simple_form edit_song" id="edit_song_1" action="/songs/1" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="_method" value="patch" />

<div class="input string required song_title"><label class="string required" for="song_title"><abbr title="required">*</abbr> Title</label><input class="string required" type="text" value="Murder" name="song[title]" id="song_title" /></div>
<div class=\"input date required song_release_date\"><label class=\"date required\" for=\"song_release_date\"><abbr title=\"required\">*</abbr> Release date</label><input class=\"date required\" type=\"date\" name=\"song[release_date]\" id=\"song_release_date\" /></div>

  <div class=\"input string required artist_name\"><label class=\"string required\" for=\"artist_name\"><abbr title=\"required\">*</abbr> Name</label><input class=\"string required\" type=\"text\" value=\"Selecter\" name=\"artist[name]\" id=\"artist_name\" /></div>
</form>}
  end

  test "create" do
    post songs_url, params: { song: { title: "", artist_attributes: { name: "" } } }
    assert_response :success
    assert_select '.song_title span.error', "can't be blank"
    assert_select '.artist_name span.error', "can't be blank"
  end
end
