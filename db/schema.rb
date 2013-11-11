# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131111184146) do

  create_table "buckets", :force => true do |t|
    t.string   "name",                               :null => false
    t.string   "slug",                               :null => false
    t.datetime "bulk_csv_created_at"
    t.integer  "bulk_csv_filesize"
    t.integer  "import_series",       :default => 0
  end

  create_table "events", :force => true do |t|
    t.integer  "bucket_id",                                                                                     :null => false
    t.datetime "datetime",                                                                                      :null => false
    t.string   "location"
    t.text     "description"
    t.spatial  "coords",         :limit => {:srid=>4326, :type=>"point", :geographic=>true}
    t.string   "row_checksum"
    t.integer  "import_series",                                                              :default => 0
    t.integer  "place_id"
    t.string   "geocode_status",                                                             :default => "new"
  end

  add_index "events", ["coords"], :name => "index_events_on_coords", :spatial => true
  add_index "events", ["row_checksum"], :name => "index_events_on_row_checksum"

  create_table "places", :force => true do |t|
    t.string   "address",                                                                                       :null => false
    t.string   "geocode_status",                                                             :default => "new"
    t.spatial  "coords",         :limit => {:srid=>4326, :type=>"point", :geographic=>true}
    t.datetime "created_at",                                                                                    :null => false
    t.datetime "updated_at",                                                                                    :null => false
  end

end
