module Carts
  class UpdateQuantity
    def self.call(cart, product, quantity)
      new(cart, product, quantity).call
    end

    def initialize(cart, product, quantity)
      @cart = cart
      @product = product
      @quantity = quantity
    end

    def call
      validate_quantity!
      
      cart_item = find_cart_item
      unless cart_item
        return { success: false, error: 'Product not found in cart' }
      end
      
      ActiveRecord::Base.transaction do
        validation_result = validate_product_availability
        unless validation_result[:success]
          return validation_result
        end
        
        stock_validation_result = validate_stock_availability(cart_item)
        unless stock_validation_result[:success]
          return stock_validation_result
        end
        
        adjust_product_stock(cart_item)
        update_item_quantity(cart_item)
      end
      
      { success: true, cart: @cart }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, error: e.message }
    end
    
    private
    
    def validate_product_availability
      if @product.inactive?
        return { success: false, error: 'Product is inactive' }
      end
      
      if @product.out_of_stock?
        return { success: false, error: 'Product is out of stock' }
      end
      
      { success: true }
    end
    
    def validate_stock_availability(cart_item)
      stock_difference = @quantity - cart_item.quantity
      
      if stock_difference > 0 && @product.stock_quantity < stock_difference
        return { success: false, error: 'Not enough stock' }
      end
      
      { success: true }
    end
    
    def adjust_product_stock(cart_item)
      stock_difference = @quantity - cart_item.quantity
      
      if stock_difference > 0
        @product.decrement!(:stock_quantity, stock_difference)
      elsif stock_difference < 0
        @product.increment!(:stock_quantity, -stock_difference)
      end
    end

    private

    def validate_quantity!
      raise ArgumentError, 'Quantity must be positive' if @quantity <= 0
    end

    def find_cart_item
      @cart.cart_items.find_by(product: @product)
    end

    def update_item_quantity(cart_item)
      cart_item.update!(quantity: @quantity)
      update_cart_totals
    end

    def update_cart_totals
      @cart.update_total_price!
      @cart.touch
    end
  end
end