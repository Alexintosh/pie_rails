class CreateStocks < ActiveRecord::Migration[5.2]
  def change
    create_table :stocks do |t|
      t.bigint :cca_id, :null => false
      t.date :run_date, :null => false
      t.string :company_name, :limit => 128, :null => false
      t.string :sector, :limit => 64, :null => false
      t.numeric :forecast_e, :precision => 8, :scale => 4
      t.numeric :forecast_s, :precision => 8, :scale => 4
      t.numeric :forecast_g, :precision => 8, :scale => 4
      t.numeric :alpha, :precision => 8, :scale => 4
      t.float :m1_return
      t.float :m3_return
      t.float :m6_return
      t.float :y1_return
      t.numeric :price, :precision => 10, :scale => 4

      t.timestamps
    end
    
    add_index :stocks, [:cca_id, :run_date], :unique => true
  end
end
