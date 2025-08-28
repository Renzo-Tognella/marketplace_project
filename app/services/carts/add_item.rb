module Carts
  class AddItem
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
      
      ActiveRecord::Base.transaction do
        validation_result = validate_product_availability
        unless validation_result[:success]
          return validation_result
        end
        
        existing_item = find_existing_item
        new_quantity = calculate_new_quantity(existing_item)
        
        stock_validation_result = validate_stock_availability(new_quantity)
        unless stock_validation_result[:success]
          return stock_validation_result
        end
        
        update_product_stock
        update_cart_item(existing_item)
        update_cart_totals
      end
      
      { success: true, cart: @cart }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, error: e.message }
    end



    def validate_product_availability
      if @product.inactive?
        return { success: false, error: 'Product is inactive' }
      end
      
      if @product.out_of_stock?
        return { success: false, error: 'Product is out of stock' }
      end
      
      { success: true }
    end

    def calculate_new_quantity(existing_item)
      if existing_item
        existing_item.quantity + @quantity
      else
        @quantity
      end
    end

    def validate_stock_availability(new_quantity)
      if @product.stock_quantity < new_quantity
        return { success: false, error: 'Not enough stock' }
      end
      
      { success: true }
    end

    def update_product_stock
      @product.decrement!(:stock_quantity, @quantity)
    end

    def update_cart_item(existing_item)
      if existing_item
        update_existing_item(existing_item)
      else
        create_new_item
      end
    end

    private

    def validate_quantity!
      raise ArgumentError, 'Quantity must be positive' if @quantity <= 0
    end

    def find_existing_item
      @cart.cart_items.find_by(product: @product)
    end

    def update_existing_item(item)
      item.update!(quantity: item.quantity + @quantity)
    end

    def create_new_item
      @cart.cart_items.create!(product: @product, quantity: @quantity)
    end

    def update_cart_totals
      @cart.update_total_price!
      @cart.touch
    end
  end
end