module Carts
  class RemoveItem
    def self.call(cart, product)
      new(cart, product).call
    end

    def initialize(cart, product)
      @cart = cart
      @product = product
    end

    def call
      cart_item = find_cart_item
      
      if cart_item
        ActiveRecord::Base.transaction do
          # Restaura o estoque antes de remover o item
          @product.increment!(:stock_quantity, cart_item.quantity)
          remove_item(cart_item)
        end
        { success: true, cart: @cart }
      else
        { success: false, error: 'Product not found in cart' }
      end
    end

    private

    def find_cart_item
      @cart.cart_items.find_by(product: @product)
    end

    def remove_item(cart_item)
      cart_item.destroy
      update_cart_totals
    end

    def update_cart_totals
      @cart.update_total_price!
      @cart.touch
    end
  end
end