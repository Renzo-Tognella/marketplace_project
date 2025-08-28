require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
  end

  describe '#total_price' do
    let(:product) { create(:product, price: 25.0) }
    let(:cart_item) { create(:cart_item, product: product, quantity: 3) }

    it 'calculates total price correctly' do
      expect(cart_item.total_price).to eq(75.0)
    end
  end
end
