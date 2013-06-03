class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :bucket_id, null: false

      # meta
      t.date :date, null: false
      t.string :location
      t.string :description

      # maintenance
      t.boolean :geocoded, default: false

      # geospatial
      t.point :coords, geographic: true

      t.timestamps
    end

    change_table :events do |t|
      t.index :coords, spatial: true
    end
  end
end
