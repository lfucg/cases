class LinkEventsToPlaces < ActiveRecord::Migration
  def up
    add_column :events, :place_id, :integer
  end

  def down
    remove_column :events, :place_id
  end
end
