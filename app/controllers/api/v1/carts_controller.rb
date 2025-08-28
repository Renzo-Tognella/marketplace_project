module Api
  module V1
    class CartsController < BaseController
      include ErrorHandler
      include CartSession

      before_action :find_product, only: [:add_item, :remove_item, :update_item]

      def show
        cart = Carts::FindOrCreate.call(session[:cart_id])

        session[:cart_id] = cart.id

        render_success(CartSerializer.serialize(cart))
      end

      def create
        cart = Carts::FindOrCreate.call

        session[:cart_id] = cart.id
        
        render_success(CartSerializer.serialize(cart), :created)
      end

      def add_item
        quantity = params[:quantity]&.to_i || 1
        result = Carts::AddItem.call(current_cart, @product, quantity)
        
        if result[:success]
          render_success(CartSerializer.serialize(result[:cart]))
        else
          render_error(result[:error], :unprocessable_entity)
        end
      end

      def remove_item
        result = Carts::RemoveItem.call(current_cart, @product)
        
        if result[:success]
          render_success(CartSerializer.serialize(result[:cart]))
        else
          render_error(result[:error], :not_found)
        end
      end

      def update_item
        quantity = params[:quantity]&.to_i
      
      if quantity.nil?
        return render_error('Quantity is required', :bad_request)
      end
        
        result = Carts::UpdateQuantity.call(current_cart, @product, quantity)
        
        if result[:success]
          render_success(CartSerializer.serialize(result[:cart]))
        else
          render_error(result[:error], :not_found)
        end
      end

      def clear
        cart = Carts::Clear.call(current_cart)
        render_success(CartSerializer.serialize(cart))
      end
    end
  end
end