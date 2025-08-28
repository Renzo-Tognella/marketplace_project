class AddFieldsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :description, :text
    add_column :products, :stock_quantity, :integer, default: 0, null: false
    add_column :products, :category, :string
    add_column :products, :status, :string, default: 'active', null: false
    
    add_index :products, :category
    add_index :products, :status
  end
end
