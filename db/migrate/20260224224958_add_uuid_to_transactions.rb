class AddUuidToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :transactions, :uuid, unique: true
  end
end
