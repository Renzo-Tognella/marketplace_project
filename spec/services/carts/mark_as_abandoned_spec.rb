require 'rails_helper'

RSpec.describe Carts::MarkAsAbandoned do
  let!(:recent_cart) { create(:cart, updated_at: 1.hour.ago, abandoned: false) }
  let!(:old_cart) { create(:cart, updated_at: 4.hours.ago, abandoned: false) }
  let!(:very_old_cart) { create(:cart, updated_at: 10.hours.ago, abandoned: false) }
  let!(:already_abandoned_cart) { create(:cart, updated_at: 5.hours.ago, abandoned: true) }
  
  describe '#call' do
    it 'marks carts as abandoned after 3 hours of inactivity' do
      result = described_class.new.call
      
      expect(result).to eq(2)
      expect(recent_cart.reload.abandoned).to be false
      expect(old_cart.reload.abandoned).to be true
      expect(very_old_cart.reload.abandoned).to be true
      expect(already_abandoned_cart.reload.abandoned).to be true
    end
    
    it 'does not affect recent carts' do
      described_class.new.call
      
      expect(recent_cart.reload.abandoned).to be false
    end
    
    it 'does not change already abandoned carts' do
      original_updated_at = already_abandoned_cart.updated_at
      
      described_class.new.call
      
      expect(already_abandoned_cart.reload.abandoned).to be true
      expect(already_abandoned_cart.updated_at).to be_within(1.second).of(original_updated_at)
    end
    
    it 'updates the updated_at timestamp for newly abandoned carts' do
      old_updated_at = old_cart.updated_at
      very_old_updated_at = very_old_cart.updated_at
      
      described_class.new.call
      
      expect(old_cart.reload.updated_at).to be > old_updated_at
      expect(very_old_cart.reload.updated_at).to be > very_old_updated_at
    end
  end
  
  describe '.call' do
    it 'delegates to instance method' do
      expect_any_instance_of(described_class).to receive(:call).and_return(1)
      described_class.call
    end
  end
end