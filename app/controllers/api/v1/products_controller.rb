module Api
  module V1
    class ProductsController < BaseController
      include ErrorHandler
      
      before_action :set_product, only: %i[ show update destroy ]

      def index
        @products = Product.all
        render_success(ProductSerializer.serialize_collection(@products))
      end

      def show
        render_success(ProductSerializer.serialize(@product))
      end

      def create
        @product = Product.new(product_params)

        if @product.save
          render_success(ProductSerializer.serialize(@product), :created)
        else
          render_error('Validation failed', :unprocessable_entity)
        end
      end

      def update
        if @product.update(product_params)
          render_success(ProductSerializer.serialize(@product))
        else
          render_error('Validation failed', :unprocessable_entity)
        end
      end

      def destroy
        @product.destroy!
        head :no_content
      end

      private

      def set_product
        @product = Product.find(params[:id])
      end

      def product_params
        params.require(:product).permit(:name, :price, :category, :stock_quantity)
      end
    end
  end
end