require 'rails_helper'

RSpec.describe Carts::UpdateQuantity do
  describe '.call' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10.0, stock_quantity: 10) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }
    let(:new_quantity) { 5 }

    subject { described_class.call(cart, product, new_quantity) }

    context 'when increasing quantity' do
      it 'updates cart item quantity' do
        expect { subject }.to change { cart_item.reload.quantity }.from(2).to(5)
      end

      it 'decrements product stock' do
        expect { subject }.to change { product.reload.stock_quantity }.by(-3)
      end

      it 'updates cart total price' do
        expect { subject }.to change { cart.reload.total_price }.to(50.0)
      end

      it 'returns success result' do
        result = subject
        expect(result[:success]).to be true
        expect(result[:cart]).to eq(cart)
      end
    end

    context 'when decreasing quantity' do
      let(:new_quantity) { 1 }

      it 'updates cart item quantity' do
        expect { subject }.to change { cart_item.reload.quantity }.from(2).to(1)
      end

      it 'increments product stock' do
        expect { subject }.to change { product.reload.stock_quantity }.by(1)
      end

      it 'updates cart total price' do
        expect { subject }.to change { cart.reload.total_price }.to(10.0)
      end
    end

    context 'when quantity remains the same' do
      let(:new_quantity) { 2 }

      it 'does not change product stock' do
        expect { subject }.not_to change { product.reload.stock_quantity }
      end

      it 'returns success result' do
        result = subject
        expect(result[:success]).to be true
      end
    end

    context 'with multiple products in cart' do
      let(:product2) { create(:product, price: 30.0, stock_quantity: 15) }
      let(:product3) { create(:product, price: 45.0, stock_quantity: 8) }
      let!(:cart_item2) { create(:cart_item, cart: cart, product: product2, quantity: 2) }
      let!(:cart_item3) { create(:cart_item, cart: cart, product: product3, quantity: 1) }
      let(:new_quantity) { 5 }

      it 'updates only the specified product quantity' do
        expect { subject }.to change { cart_item.reload.quantity }.from(2).to(5)
        expect(cart_item2.reload.quantity).to eq(2)
        expect(cart_item3.reload.quantity).to eq(1)
      end

      it 'adjusts stock only for the updated product' do
        expect { subject }.to change { product.reload.stock_quantity }.by(-3)
        expect(product2.reload.stock_quantity).to eq(15)
        expect(product3.reload.stock_quantity).to eq(8)
      end

      it 'recalculates total price correctly' do
        cart.update_total_price!
        initial_total = cart.reload.total_price
        subject
        price_difference = product.price * (new_quantity - cart_item.quantity)
        expected_total = initial_total + price_difference
        expect(cart.reload.total_price).to eq(expected_total)
      end
    end

    context 'with quantity reduction in multi-product cart' do
      let(:product2) { create(:product, price: 25.0, stock_quantity: 5) }
      let!(:cart_item2) { create(:cart_item, cart: cart, product: product2, quantity: 3) }
      let(:new_quantity) { 1 }

      it 'reduces quantity and restores stock' do
        expect { subject }.to change { cart_item.reload.quantity }.from(2).to(1)
      end
      
      it 'restores stock correctly' do
        expect { subject }.to change { product.reload.stock_quantity }.by(1)
      end

      it 'maintains other products unchanged' do
        subject
        expect(cart_item2.reload.quantity).to eq(3)
        expect(product2.reload.stock_quantity).to eq(5)
      end

      it 'reduces total price correctly' do
        cart.update_total_price!
        initial_total = cart.reload.total_price
        subject
        price_reduction = product.price * 1
        expected_total = initial_total - price_reduction
        expect(cart.reload.total_price).to eq(expected_total)
      end
    end

    context 'with high volume updates' do
      let(:products) { create_list(:product, 4, price: 20.0, stock_quantity: 50) }
      let(:cart_items) do
        products.map.with_index do |prod, index|
          create(:cart_item, cart: cart, product: prod, quantity: (index + 1) * 2)
        end
      end
      let(:cart_item) { cart_items.first }
      let(:product) { products.first }
      let(:new_quantity) { 15 }

      before { cart_items }

      it 'handles large quantity increase' do
        expect { subject }.to change { cart_item.reload.quantity }.from(2).to(15)
      end

      it 'decrements stock by correct amount' do
        expect { subject }.to change { product.reload.stock_quantity }.by(-13)
      end

      it 'maintains other cart items' do
        subject
        expect(cart_items[1].reload.quantity).to eq(4)
        expect(cart_items[2].reload.quantity).to eq(6)
        expect(cart_items[3].reload.quantity).to eq(8)
      end
    end

    context 'with different product categories' do
      let(:electronics_product) { create(:product, category: 'electronics', price: 200.0, stock_quantity: 3) }
      let(:clothing_product) { create(:product, category: 'clothing', price: 80.0, stock_quantity: 12) }
      let!(:electronics_item) { create(:cart_item, cart: cart, product: electronics_product, quantity: 1) }
      let!(:clothing_item) { create(:cart_item, cart: cart, product: clothing_product, quantity: 2) }
      let(:new_quantity) { 6 }

      it 'updates product quantity in mixed category cart' do
        expect { subject }.to change { cart_item.reload.quantity }.from(2).to(6)
      end

      it 'maintains category diversity' do
        subject
        categories = cart.cart_items.includes(:product).map { |item| item.product.category }.uniq
        expect(categories.size).to be >= 2
      end

      it 'calculates total across categories' do
        subject
        expected_total = (product.price * 6) + (electronics_product.price * 1) + (clothing_product.price * 2)
        expect(cart.reload.total_price).to eq(expected_total)
      end
    end

    context 'with edge case scenarios' do
      context 'when updating to maximum available stock' do
        let(:product) { create(:product, price: 15.0, stock_quantity: 7) }
        let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }
        let(:new_quantity) { 9 }

        it 'uses all available stock' do
          expect { subject }.to change { product.reload.stock_quantity }.from(7).to(0)
        end

        it 'updates to maximum possible quantity' do
          expect { subject }.to change { cart_item.reload.quantity }.from(2).to(9)
        end
      end

      context 'when reducing to minimum quantity' do
        let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 10) }
        let(:new_quantity) { 1 }

        it 'reduces to single item' do
          expect { subject }.to change { cart_item.reload.quantity }.from(10).to(1)
        end

        it 'restores significant stock' do
          expect { subject }.to change { product.reload.stock_quantity }.by(9)
        end
      end
    end

    context 'when product not in cart' do
      let(:other_product) { create(:product) }

      subject { described_class.call(cart, other_product, 3) }

      it 'returns error result' do
        result = subject
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Product not found in cart')
      end
    end

    context 'when product is inactive' do
      before { product.deactivate! }

      it 'returns error result' do
        result = subject
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Product is inactive')
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

    context 'when not enough stock for increase' do
      let(:new_quantity) { 15 }

      it 'returns error result' do
        result = subject
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Not enough stock')
      end
    end

    context 'when quantity is invalid' do
      let(:new_quantity) { 0 }

      it 'raises ArgumentError' do
        expect { subject }.to raise_error(ArgumentError, 'Quantity must be positive')
      end
    end
  end
end