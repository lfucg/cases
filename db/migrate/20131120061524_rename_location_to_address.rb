class RenameLocationToAddress < ActiveRecord::Migration
  def up
    rename_column :events, :location, :address
  end

  def down
    rename_column :events, :address, :location
  end
end
