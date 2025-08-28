class CartSerializer
  def self.serialize(cart)
    {
      id: cart.id,
      products: cart.cart_items.includes(:product).map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price.to_f,
          total_price: (item.quantity * item.product.price).to_f
        }
      end,
      total_price: cart.total_price.to_f,
      items_count: cart.cart_items.sum(:quantity),
      created_at: cart.created_at,
      updated_at: cart.updated_at
    }
  end

  def self.serialize_error(message, status = :unprocessable_entity)
    {
      error: message,
      status: status
    }
  end
end