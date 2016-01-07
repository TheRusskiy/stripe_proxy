class CreateStripeCacheRecords < ActiveRecord::Migration
  def change
    create_table :stripe_cache_records do |t|
      t.string :key, null: false
      t.text :value
      t.timestamps null: false
    end

    add_index :stripe_cache_records, :key, unique: true
  end
end
