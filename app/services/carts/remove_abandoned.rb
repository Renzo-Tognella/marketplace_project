module Carts
  class RemoveAbandoned
    def self.call
      new.call
    end

    def call      
      remove_old_abandoned_carts
    end

    private

    def remove_old_abandoned_carts
      cutoff_time = 7.days.ago

      cart_ids = Cart.where('updated_at < ? AND abandoned = ?', cutoff_time, true).pluck(:id)
      
      ActiveRecord::Base.transaction do
        CartItem.where(cart_id: cart_ids).delete_all
        
        Cart.where(id: cart_ids).delete_all
      end
    end
  end
end