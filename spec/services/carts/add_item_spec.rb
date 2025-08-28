require 'rails_helper'

RSpec.describe Carts::AddItem do
  describe '.call' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10.0, stock_quantity: 5) }
    let(:quantity) { 2 }

    subject { described_class.call(cart, product, quantity) }

    context 'when adding a new item' do
      it 'creates a new cart item' do
        expect { subject }.to change { cart.cart_items.count }.by(1)
      end

      it 'sets the correct quantity' do
        subject
        cart_item = cart.cart_items.find_by(product: product)
        expect(cart_item.quantity).to eq(quantity)
      end

      it 'decrements product stock' do
        expect { subject }.to change { product.reload.stock_quantity }.by(-quantity)
      end

      it 'updates cart total price' do
        expect { subject }.to change { cart.reload.total_price }.to(20.0)
      end

      it 'returns success result' do
        result = subject
        expect(result[:success]).to be true
        expect(result[:cart]).to eq(cart)
      end
    end

    context 'when adding to existing item' do
      let!(:existing_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      it 'does not create a new cart item' do
        expect { subject }.not_to change { cart.cart_items.count }
      end

      it 'updates existing item quantity' do
        expect { subject }.to change { existing_item.reload.quantity }.from(1).to(3)
      end

      it 'decrements product stock' do
        expect { subject }.to change { product.reload.stock_quantity }.by(-quantity)
      end
    end

    context 'when product is inactive' do
      before { product.deactivate! }

      it 'returns error result' do
        result = subject
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Product is inactive')
      end

      it 'does not create cart item' do
        expect { subject }.not_to change { cart.cart_items.count }
      end
    end

    context 'when product is out of stock' do
      before { product.mark_out_of_stock! }

      it 'returns error result' do
        result = subject
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Product is out of stock')
      end
    end

    context 'when not enough stock' do
      let(:quantity) { 10 }

      it 'returns error result' do
        result = subject
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Not enough stock')
      end
    end

    context 'when quantity is invalid' do
      let(:quantity) { 0 }

      it 'raises ArgumentError' do
        expect { subject }.to raise_error(ArgumentError, 'Quantity must be positive')
      end
    end

    context 'with multiple products in cart' do
      let(:product2) { create(:product, price: 25.0, stock_quantity: 10) }
      let(:product3) { create(:product, price: 15.0, stock_quantity: 8) }
      let!(:existing_item2) { create(:cart_item, cart: cart, product: product2, quantity: 2) }
      let!(:existing_item3) { create(:cart_item, cart: cart, product: product3, quantity: 1) }

      it 'adds new product to cart with existing products' do
        expect { subject }.to change { cart.cart_items.count }.by(1)
      end

      it 'calculates correct total price with multiple products' do
        cart.update_total_price!
        initial_total = cart.reload.total_price
        subject
        expected_total = initial_total + (product.price * quantity)
        expect(cart.reload.total_price).to eq(expected_total)
      end

      it 'maintains existing items unchanged' do
        subject
        expect(existing_item2.reload.quantity).to eq(2)
        expect(existing_item3.reload.quantity).to eq(1)
      end
    end

    context 'with cart containing multiple items of same product' do
      let!(:existing_item) { create(:cart_item, cart: cart, product: product, quantity: 3) }
      let(:quantity) { 2 }

      it 'increases existing item quantity correctly' do
        expect { subject }.to change { existing_item.reload.quantity }.from(3).to(5)
      end

      it 'decrements stock by added quantity only' do
        expect { subject }.to change { product.reload.stock_quantity }.by(-quantity)
      end

      it 'updates total price correctly' do
        cart.update_total_price!
        initial_total = cart.reload.total_price
        subject
        expected_total = initial_total + (product.price * quantity)
        expect(cart.reload.total_price).to eq(expected_total)
      end
    end

    context 'with complex cart scenario' do
      let(:electronics_product) { create(:product, category: 'electronics', price: 100.0, stock_quantity: 5) }
      let(:clothing_product) { create(:product, category: 'clothing', price: 50.0, stock_quantity: 10) }
      let(:food_product) { create(:product, category: 'food', price: 20.0, stock_quantity: 15) }
      
      let!(:electronics_item) { create(:cart_item, cart: cart, product: electronics_product, quantity: 1) }
      let!(:clothing_item) { create(:cart_item, cart: cart, product: clothing_product, quantity: 2) }
      
      let(:product) { food_product }
      let(:quantity) { 3 }

      it 'adds food product to cart with electronics and clothing' do
        expect { subject }.to change { cart.cart_items.count }.from(2).to(3)
      end

      it 'calculates total price across different categories' do
        subject
        expected_total = (electronics_product.price * 1) + (clothing_product.price * 2) + (food_product.price * 3)
        expect(cart.reload.total_price).to eq(expected_total)
      end

      it 'maintains category diversity in cart' do
        subject
        categories = cart.cart_items.includes(:product).map { |item| item.product.category }.uniq
        expect(categories).to contain_exactly('electronics', 'clothing', 'food')
      end
    end

    context 'with high volume scenario' do
      let(:products) { create_list(:product, 5, price: 10.0, stock_quantity: 100) }
      let(:product) { products.first }
      let(:quantity) { 10 }

      before do
        products[1..4].each_with_index do |prod, index|
          create(:cart_item, cart: cart, product: prod, quantity: (index + 1) * 2)
        end
      end

      it 'handles adding to cart with multiple existing products' do
        expect { subject }.to change { cart.cart_items.count }.by(1)
      end

      it 'calculates correct total with high quantities' do
        cart.update_total_price!
        initial_total = cart.reload.total_price
        subject
        expected_addition = product.price * quantity
        expect(cart.reload.total_price).to eq(initial_total + expected_addition)
      end

      it 'decrements stock correctly for high quantity' do
        expect { subject }.to change { product.reload.stock_quantity }.by(-quantity)
      end
    end

    context 'with edge case quantities' do
      let(:quantity) { 1 }
      
      context 'when adding single item to empty cart' do
        it 'creates first item in cart' do
          expect { subject }.to change { cart.cart_items.count }.from(0).to(1)
        end

        it 'sets total price to product price' do
          expect { subject }.to change { cart.reload.total_price }.to(product.price)
        end
      end

      context 'when adding to cart at stock limit' do
        let(:product) { create(:product, price: 10.0, stock_quantity: 1) }
        
        it 'successfully adds last available item' do
          expect { subject }.to change { cart.cart_items.count }.by(1)
        end

        it 'reduces stock to zero' do
          expect { subject }.to change { product.reload.stock_quantity }.from(1).to(0)
        end
      end
    end
  end
end