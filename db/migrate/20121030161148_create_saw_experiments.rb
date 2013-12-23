class CreateSawExperiments < ActiveRecord::Migration
  def change
    create_table :saw_experiments do |t|
      t.integer :task_id
      t.string :mturk_worker_id
      t.datetime :created_at
    end
    add_index :saw_experiments, :task_id
    add_index :saw_experiments, :mturk_worker_id
  end
end
