module Carts
  class Clear
    def self.call(cart)
      new(cart).call
    end

    def initialize(cart)
      @cart = cart
    end

    def call
      clear_all_items
      reset_cart_totals
      @cart
    end
    
    private

    def clear_all_items
      @cart.cart_items.destroy_all
    end

    def reset_cart_totals
      @cart.update!(total_price: 0)
      @cart.touch
    end
  end
end