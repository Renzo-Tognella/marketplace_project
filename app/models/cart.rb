class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  
  def calculate_total_price
    cart_items.joins(:product).sum('cart_items.quantity * products.price')
  end

  def update_total_price!
    update!(total_price: calculate_total_price)
  end
end
