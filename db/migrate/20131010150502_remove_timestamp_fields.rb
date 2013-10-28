class RemoveTimestampFields < ActiveRecord::Migration
  def up
    remove_column :events, :created_at
    remove_column :events, :updated_at
  end

  def down
    add_column :events, :created_at, :datetime
    add_column :events, :updated_at, :datetime
  end
end
