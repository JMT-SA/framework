# frozen_string_literal: true

module PackMaterialApp
  class MrDeliveryItemInteractor < BaseInteractor
    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_delivery_item(id)
      repo.find_mr_delivery_item(id)
    end

    def validate_mr_delivery_item_params(params)
      MrDeliveryItemSchema.call(params)
    end

    def create_mr_delivery_item(parent_id, params)
      params[:mr_delivery_id] = parent_id
      res = validate_mr_delivery_item_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_mr_delivery_item(res)
        log_status('mr_delivery_items', id, 'CREATED')
        log_transaction
      end
      instance = mr_delivery_item(id)
      success_response("Created delivery item #{instance.remarks}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { remarks: ['This delivery item already exists'] }))
    end

    def update_mr_delivery_item(id, params)
      res = validate_mr_delivery_item_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_delivery_item(id, res)
        log_transaction
      end
      instance = mr_delivery_item(id)
      success_response("Updated delivery item #{instance.remarks}",
                       instance)
    end

    def delete_mr_delivery_item(id)
      name = mr_delivery_item(id).remarks
      repo.transaction do
        repo.delete_mr_delivery_item(id)
        log_status('mr_delivery_items', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted delivery item #{name}")
    end

    def available_purchase_order_items(purchase_order_id, delivery_id)
      repo.for_select_remaining_purchase_order_items(purchase_order_id, delivery_id)
    end

    def purchase_order_id_for_delivery_item(delivery_item_id)
      repo.purchase_order_id_for_delivery_item(delivery_item_id)
    end
  end
end
