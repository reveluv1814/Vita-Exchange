class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :from_currency, null: false
      t.string :to_currency, null: false
      t.decimal :amount_from, precision: 20, scale: 8, null: false
      t.decimal :amount_to, precision: 20, scale: 8, null: false
      t.decimal :rate, precision: 20, scale: 8, null: false
      t.string :status, default: 'pending', null: false
      t.text :error_message

      t.timestamps
    end
    add_index :transactions, :status
  end
end
