module Carts
  class MarkAsAbandoned
    def self.call
      new.call
    end

    def call      
      mark_abandoned_carts
    end

    private

    def mark_abandoned_carts
      cutoff_time = 3.hours.ago
      current_time = Time.current
      
      affected_rows = Cart.where(
        'updated_at < ? AND abandoned = ?', 
        cutoff_time, 
        false
      ).update_all(
        abandoned: true, 
        updated_at: current_time
      )
      
      affected_rows
    end
  end
end