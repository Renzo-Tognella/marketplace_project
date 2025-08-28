require 'rails_helper'

RSpec.describe Carts::FindOrCreate do
  describe '.call' do
    context 'when cart_id is nil' do
      subject { described_class.call(nil) }

      it 'creates a new cart' do
        expect { subject }.to change { Cart.count }.by(1)
      end

      it 'returns the new cart with zero total price' do
        cart = subject
        expect(cart.total_price).to eq(0)
        expect(cart).to be_persisted
      end
    end

    context 'when cart_id is blank' do
      subject { described_class.call('') }

      it 'creates a new cart' do
        expect { subject }.to change { Cart.count }.by(1)
      end

      it 'returns the new cart' do
        cart = subject
        expect(cart.total_price).to eq(0)
        expect(cart).to be_persisted
      end
    end

    context 'when cart_id exists' do
      let!(:existing_cart) { create(:cart, total_price: 50.0) }

      subject { described_class.call(existing_cart.id) }

      it 'does not create a new cart' do
        expect { subject }.not_to change { Cart.count }
      end

      it 'returns the existing cart' do
        cart = subject
        expect(cart).to eq(existing_cart)
        expect(cart.total_price).to eq(50.0)
      end
    end

    context 'when cart_id does not exist' do
      subject { described_class.call(999) }

      it 'creates a new cart' do
        expect { subject }.to change { Cart.count }.by(1)
      end

      it 'returns the new cart' do
        cart = subject
        expect(cart.total_price).to eq(0)
        expect(cart).to be_persisted
      end
    end
  end
end