require 'rails_helper'

RSpec.describe Carts::RemoveAbandoned do
  let!(:recent_abandoned_cart) { create(:cart, updated_at: 5.days.ago, abandoned: true) }
  let!(:old_abandoned_cart) { create(:cart, updated_at: 8.days.ago, abandoned: true) }
  let!(:very_old_abandoned_cart) { create(:cart, updated_at: 15.days.ago, abandoned: true) }
  let!(:old_active_cart) { create(:cart, updated_at: 10.days.ago, abandoned: false) }
  
  describe '#call' do
    it 'removes abandoned carts older than 7 days' do
      result = described_class.new.call
      
      expect(result).to eq(2)
      expect(Cart.exists?(recent_abandoned_cart.id)).to be true
      expect(Cart.exists?(old_abandoned_cart.id)).to be false
      expect(Cart.exists?(very_old_abandoned_cart.id)).to be false
      expect(Cart.exists?(old_active_cart.id)).to be true
    end
    
    it 'does not remove recent abandoned carts' do
      described_class.new.call
      
      expect(Cart.exists?(recent_abandoned_cart.id)).to be true
    end
    
    it 'does not remove old active carts' do
      described_class.new.call
      
      expect(Cart.exists?(old_active_cart.id)).to be true
    end
    
    context 'when carts have associated cart items' do
      let!(:cart_with_items) { create(:cart, updated_at: 10.days.ago, abandoned: true) }
      let!(:product) { create(:product, stock_quantity: 10) }
      let!(:cart_item) { create(:cart_item, cart: cart_with_items, product: product, quantity: 2) }
      
      it 'removes cart items along with the cart' do
        expect(CartItem.exists?(cart_item.id)).to be true
        
        described_class.new.call
        
        expect(Cart.exists?(cart_with_items.id)).to be false
        expect(CartItem.exists?(cart_item.id)).to be false
      end
    end
    
    context 'when no abandoned carts exist' do
      before do
        Cart.update_all(abandoned: false)
      end
      
      it 'returns zero' do
        result = described_class.new.call
        
        expect(result).to eq(0)
      end
    end
  end
  
  describe '.call' do
    it 'delegates to instance method' do
      expect_any_instance_of(described_class).to receive(:call).and_return(1)
      described_class.call
    end
  end
end