class AddPerformanceIndexesToCarts < ActiveRecord::Migration[7.0]
  def change
    add_index :carts, :updated_at, name: 'index_carts_on_updated_at'
  end
end