class CreateBigBrotherTracks < ActiveRecord::Migration
  def change
    create_table :big_brother_tracks do |t|
      t.string :mturk_worker_id
      t.string :ip
      t.string :controller
      t.string :action
      t.string :method
      t.boolean :ajax
      t.datetime :created_at
    end
    add_index :big_brother_tracks, :mturk_worker_id
  end
end
