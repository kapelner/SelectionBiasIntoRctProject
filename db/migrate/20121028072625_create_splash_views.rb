class CreateSplashViews < ActiveRecord::Migration
  def change
    create_table :splash_views do |t|
      t.string :ip_address
      t.datetime :created_at
    end
    add_index :splash_views, :ip_address
  end
end
