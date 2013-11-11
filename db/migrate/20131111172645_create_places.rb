class CreatePlaces < ActiveRecord::Migration
  def up
    create_table :places do |t|
      t.string :address, null: false

      # Status could be new, complete, failed
      t.string :geocode_status, default: 'new'

      # geospatial
      t.point :coords, geographic: true

      t.timestamps
    end
  end

  def down
    drop_table :places
  end
end
