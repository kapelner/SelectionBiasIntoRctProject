class AddOutlierToStudy < ActiveRecord::Migration
  def change
    add_column :studies, :outlier, :boolean, :null => false, :default => false
  end
end
