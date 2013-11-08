class AddBulkDownloadInfoToBuckets < ActiveRecord::Migration
  def change
    add_column :buckets, :bulk_csv_created_at, :datetime
    add_column :buckets, :bulk_csv_filesize, :integer
  end
end
