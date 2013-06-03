class CreateBuckets < ActiveRecord::Migration
  def change
    create_table :buckets do |t|
      t.string :name, null: false
      t.string :slug, null: false
    end
  end
end
