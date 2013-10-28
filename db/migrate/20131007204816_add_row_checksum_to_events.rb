class AddRowChecksumToEvents < ActiveRecord::Migration
  def change
    add_column :events, :row_checksum, :string
  end
end
