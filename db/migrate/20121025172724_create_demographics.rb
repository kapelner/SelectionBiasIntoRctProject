class CreateDemographics < ActiveRecord::Migration
  def change
    create_table :demographics do |t|
      t.string :mturk_worker_id
      t.integer :age
      t.string :gender, :limit => 1
      t.string :urban_rural, :limit => 1
      t.string :highest_education
      t.string :marital_status
      t.string :employment_status
      t.integer :num_children, :limit => 2
      t.integer :income
      t.string :religion
      t.string :belief_in_divine, :limit => 1
      t.string :race
      t.string :participate_in_study, :limit => 1
      t.string :born_here
      t.string :english_first_language
      t.boolean :nfc_1
      t.boolean :nfc_2
      t.boolean :big_5_1
      t.boolean :big_5_2
      t.boolean :big_5_3
      t.boolean :big_5_4
      t.boolean :big_5_5
      t.datetime :completed_at
      t.datetime :created_at
    end
    add_index :demographics, :mturk_worker_id
  end
end
