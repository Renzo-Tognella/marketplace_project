require 'rails_helper'

RSpec.describe Carts::Clear do
  describe '.call' do
    let(:cart) { create(:cart, total_price: 100.0) }
    let(:product1) { create(:product, price: 20.0) }
    let(:product2) { create(:product, price: 30.0) }

    before do
      create(:cart_item, cart: cart, product: product1, quantity: 2)
      create(:cart_item, cart: cart, product: product2, quantity: 1)
    end

    subject { described_class.call(cart) }

    it 'removes all cart items' do
      expect { subject }.to change { cart.cart_items.count }.from(2).to(0)
    end

    it 'resets cart total price to zero' do
      expect { subject }.to change { cart.reload.total_price }.to(0.0)
    end

    it 'returns the cart' do
      result = subject
      expect(result).to eq(cart)
    end

    it 'touches the cart to update timestamps' do
      expect(cart).to receive(:touch)
      subject
    end
  end
end