class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|
      t.integer :task_id
      t.string :study_name
      t.decimal :response, :precision => 20, :scale => 6
      t.datetime :responded_at
      t.integer :num_page_nav_away, :null => false, :default => 0
      t.datetime :created_at
    end
  end
end
