require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'associations' do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:products).through(:cart_items) }
  end

  describe '#calculate_total_price' do
    let(:cart) { create(:cart) }
    let(:product1) { create(:product, price: 10.0) }
    let(:product2) { create(:product, price: 20.0) }

    context 'when cart has no items' do
      it 'returns 0' do
        expect(cart.calculate_total_price).to eq(0)
      end
    end

    context 'when cart has items' do
      before do
        create(:cart_item, cart: cart, product: product1, quantity: 2)
        create(:cart_item, cart: cart, product: product2, quantity: 1)
      end

      it 'calculates total price correctly' do
        expect(cart.calculate_total_price).to eq(40.0)
      end
    end
  end

  describe '#update_total_price!' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 15.0) }

    before do
      create(:cart_item, cart: cart, product: product, quantity: 3)
    end

    it 'updates the total_price attribute' do
      expect { cart.update_total_price! }.to change { cart.total_price }.to(45.0)
    end
  end
end
