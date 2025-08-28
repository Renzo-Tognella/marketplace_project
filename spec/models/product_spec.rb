require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'associations' do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:carts).through(:cart_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:price) }
    it { should validate_presence_of(:category) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:stock_quantity).is_greater_than_or_equal_to(0).only_integer }
  end

  describe 'enums' do
    it 'defines category enum with correct values' do
      expect(Product.categories).to eq({
        'electronics' => 'electronics',
        'clothing' => 'clothing',
        'automotive' => 'automotive',
        'food' => 'food',
        'health' => 'health'
      })
    end
  end

  describe 'AASM states' do
    let(:product) { create(:product) }

    it 'has initial state as active' do
      expect(product.status).to eq('active')
    end

    it 'can transition from active to inactive' do
      product.deactivate!
      expect(product.status).to eq('inactive')
    end

    it 'can transition from active to out_of_stock' do
      product.mark_out_of_stock!
      expect(product.status).to eq('out_of_stock')
    end

    it 'can transition from inactive to active' do
      product.deactivate!
      product.activate!
      expect(product.status).to eq('active')
    end

    it 'can transition from out_of_stock to active when has stock' do
      product.update!(stock_quantity: 5)
      product.mark_out_of_stock!
      product.restock!
      expect(product.status).to eq('active')
    end

    it 'cannot transition from out_of_stock to active when no stock' do
      product.update!(stock_quantity: 0)
      product.mark_out_of_stock!
      expect { product.restock! }.to raise_error(AASM::InvalidTransition)
    end
  end

  describe '#has_stock?' do
    it 'returns true when stock_quantity is greater than 0' do
      product = build(:product, stock_quantity: 5)
      expect(product.send(:has_stock?)).to be true
    end

    it 'returns false when stock_quantity is 0' do
      product = build(:product, stock_quantity: 0)
      expect(product.send(:has_stock?)).to be false
    end
  end
end
