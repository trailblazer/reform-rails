ActiveRecord::Schema.define(:version => 1) do

  create_table "songs", :force => true do |t|
    t.string   "title"
    t.integer     "composer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end
