class CreateCryptos < ActiveRecord::Migration[5.2]
  def change
    create_table :cryptos do |t|
      t.references :pie
      t.integer :pct_curr1
      t.integer :pct_curr2
      t.integer :pct_curr3

      t.timestamps
    end
  end
end
