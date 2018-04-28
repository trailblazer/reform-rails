ActiveRecord::Schema.define(version: 1) do
  create_table "songs" do |t|
    t.string   "title"
    t.date     "release_date"
    t.integer  "artist_id"
    t.integer  "album_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artists" do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "albums" do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
