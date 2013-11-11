class AddEventChecksumIndex < ActiveRecord::Migration
  def up
    add_index :events, :row_checksum
  end

  def down
    remove_index :events, :row_checksum
  end
end
