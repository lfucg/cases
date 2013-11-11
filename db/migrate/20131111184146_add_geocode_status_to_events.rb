class AddGeocodeStatusToEvents < ActiveRecord::Migration
  def change
    add_column :events, :geocode_status, :string, default: 'new'
    remove_column :events, :geocoded
  end
end
