class Product < ApplicationRecord
  include AASM
  
  has_many :cart_items, dependent: :destroy
  has_many :carts, through: :cart_items
  
  enum category: {
    electronics: 'electronics',
    clothing: 'clothing',
    automotive: 'automotive',
    food: 'food',
    health: 'health'
  }
  
  validates_presence_of :name, :price, :category
  validates_numericality_of :price, greater_than_or_equal_to: 0
  validates_numericality_of :stock_quantity, greater_than_or_equal_to: 0, only_integer: true
  
  aasm column: :status do
    state :active, initial: true
    state :inactive
    state :out_of_stock
    
    event :activate do
      transitions from: [:inactive, :out_of_stock], to: :active
    end
    
    event :deactivate do
      transitions from: :active, to: :inactive
    end
    
    event :mark_out_of_stock do
      transitions from: :active, to: :out_of_stock
    end
    
    event :restock do
      transitions from: :out_of_stock, to: :active, guard: :has_stock?
    end
  end
  
  private

  def has_stock?
    stock_quantity > 0
  end
end
