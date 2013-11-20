class AddHashedAddresses < ActiveRecord::Migration
  def up
    add_column :events, :hashed_address, :string
    add_column :places, :hashed_address, :string

    add_index :events, :hashed_address
    add_index :places, :hashed_address
  end

  def down
    remove_column :events, :hashed_address
    remove_column :places, :hashed_address

    remove_index :events, :hashed_address
    remove_index :places, :hashed_address
  end
end
