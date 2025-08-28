module CartSession
  extend ActiveSupport::Concern

  private

  def current_cart
    @current_cart ||= find_or_create_cart
  end

  def find_or_create_cart
    cart_id = session[:cart_id] || params[:cart_id]
    cart = Carts::FindOrCreate.call(cart_id)

    session[:cart_id] = cart.id
    
    cart
  end

  def find_product
    @product = Product.find(params[:product_id])
  end
end