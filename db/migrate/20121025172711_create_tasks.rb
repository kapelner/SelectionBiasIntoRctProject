class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      
      t.string :mturk_hit_id
      t.string :mturk_group_id
      t.integer :version
      t.float :wage      
      t.datetime :to_be_expired_at
      t.string :country, :limit => 2
      
      t.string :mturk_assignment_id
      t.string :mturk_worker_id
      t.string :ip_address
      t.datetime :started_at

      t.text :turker_comments
      
      t.datetime :finished_at
      t.string :browser_info

      t.datetime :rejected_at
      t.datetime :paid_at
      t.float :bonus
      t.text :notes
      
      #experimental statturk information
      t.integer :current_study_num, :limit => 3, :null => false, :default => 0
      t.text :study_list
      t.string :exp_arm, :limit => 1
      t.boolean :treatment
      t.integer :num_page_reloads, :null => false, :default => 0

      t.timestamps
    end
    
    add_index :tasks, :mturk_worker_id, :unique => true
  end
end
