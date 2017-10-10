ActiveRecord::Schema.define(:version => 1) do

  create_table "songs", :force => true do |t|
    t.string   "title"
    t.date     "release_date"
    t.integer  "artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artists", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
