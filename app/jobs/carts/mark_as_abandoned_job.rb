module Carts
  class MarkAsAbandonedJob < ApplicationJob
    queue_as :default
    
    sidekiq_options retry: 3

    def perform      
      Carts::MarkAsAbandoned.call
    end
  end
end
