module Carts
  class RemoveAbandonedJob < ApplicationJob
    queue_as :default

    sidekiq_options retry: 3

    def perform
      Carts::RemoveAbandoned.call
    end
  end
end