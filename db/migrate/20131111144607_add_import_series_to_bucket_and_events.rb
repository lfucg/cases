class AddImportSeriesToBucketAndEvents < ActiveRecord::Migration
  def change
    add_column :buckets, :import_series, :integer, default: 0
    add_column :events, :import_series, :integer, default: 0
  end
end
