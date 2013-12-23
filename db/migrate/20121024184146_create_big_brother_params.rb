class CreateBigBrotherParams < ActiveRecord::Migration
  def change
    create_table :big_brother_params do |t|
      t.string :param
      t.text :value, :limit => 10000
      t.integer :big_brother_track_id
    end
    add_index :big_brother_params, :big_brother_track_id
  end
end
