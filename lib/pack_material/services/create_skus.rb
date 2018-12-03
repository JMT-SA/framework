# frozen_string_literal: true

module PackMaterialApp
  class CreateSKUS < BaseService
    def initialize(mr_delivery_id)
      @id = mr_delivery_id
      @repo = CreateSKUSRepo.new
    end

    def call
      sku_ids = @repo.create_skus_for_delivery(@id)
      @repo.log_status('mr_deliveries', @id, 'SKUS_CREATED')
      business_process_id = @repo.delivery_process_id

      # TODO: location_code should be selected on the delivery
      CreateMrStock.call(sku_ids, business_process_id, location_code: 'RECEIVING BAY', delivery_id: @id)
    end
  end
end