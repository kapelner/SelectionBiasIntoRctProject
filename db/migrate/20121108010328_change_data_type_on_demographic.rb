class ChangeDataTypeOnDemographic < ActiveRecord::Migration
  def change
    change_column :demographics, :nfc_1, :string, :limit => 2
    change_column :demographics, :nfc_2, :string, :limit => 2
    change_column :demographics, :big_5_1, :string, :limit => 2
    change_column :demographics, :big_5_2, :string, :limit => 2
    change_column :demographics, :big_5_3, :string, :limit => 2
    change_column :demographics, :big_5_4, :string, :limit => 2
    change_column :demographics, :big_5_5, :string, :limit => 2
  end
end
