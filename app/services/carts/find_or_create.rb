module Carts
  class FindOrCreate
    def self.call(cart_id = nil)
      new(cart_id).call
    end

    def initialize(cart_id = nil)
      @cart_id = cart_id
    end

    def call
      if @cart_id.blank?
        return create_new_cart
      end
      
      find_existing_cart || create_new_cart
    end

    private

    def find_existing_cart
      Cart.find_by(id: @cart_id)
    end

    def create_new_cart
      Cart.create!(total_price: 0)
    end
  end
end