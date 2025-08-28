require 'rails_helper'

RSpec.describe Carts::RemoveItem do
  describe '.call' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 15.0, stock_quantity: 5) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 3) }

    subject { described_class.call(cart, product) }

    context 'when product exists in cart' do
      before { cart.update_total_price! }
      
      it 'removes the cart item' do
        expect { subject }.to change { cart.cart_items.count }.by(-1)
      end

      it 'restores product stock' do
        expect { subject }.to change { product.reload.stock_quantity }.by(3)
      end

      it 'updates cart total price' do
        expect { subject }.to change { cart.reload.total_price }.to(0.0)
      end

      it 'returns success result' do
        result = subject
        expect(result[:success]).to be true
        expect(result[:cart]).to eq(cart)
      end
    end

    context 'when product does not exist in cart' do
      let(:other_product) { create(:product) }

      subject { described_class.call(cart, other_product) }

      it 'does not remove any cart item' do
        expect { subject }.not_to change { cart.cart_items.count }
      end

      it 'returns error result' do
        result = subject
        expect(result[:success]).to be false
        expect(result[:error]).to eq('Product not found in cart')
      end
    end
  end
end