# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class DeliveryPutawayStatusCheck < BaseService
    def initialize(sku_id, quantity, delivery_id)
      @repo = ReplenishRepo.new
      @quantity = quantity
      @sku_id = sku_id
      @delivery_id = delivery_id
    end

    def call
      @repo.delivery_putaway_reaction_job(@sku_id, @quantity, @delivery_id)
    end
  end
end