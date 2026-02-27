class CreateWalletBalances < ActiveRecord::Migration[8.1]
  def change
    create_table :wallet_balances do |t|
      t.references :user, null: false, foreign_key: true
      t.string :currency, null: false
      t.decimal :amount, precision: 20, scale: 8, default: 0.0, null: false

      t.timestamps
    end
    add_index :wallet_balances, [:user_id, :currency], unique: true
  end
end
