# frozen_string_literal: true

module PackMaterialApp
  class MrDeliveryItemBatchInteractor < BaseInteractor
    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_delivery_item_batch(id)
      repo.find_mr_delivery_item_batch(id)
    end

    def validate_mr_delivery_item_batch_params(params)
      MrDeliveryItemBatchSchema.call(params)
    end

    def create_mr_delivery_item_batch(parent_id, params)
      params[:mr_delivery_item_id] = parent_id
      res = validate_mr_delivery_item_batch_params(params)
      res.messages[:base] = res.messages[:internal_or_client_batch_number] if res.messages && res.messages[:internal_or_client_batch_number]
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_mr_delivery_item_batch(res)
        log_status('mr_delivery_item_batches', id, 'CREATED')
        log_transaction
      end
      instance = mr_delivery_item_batch(id)
      success_response("Created mr delivery item batch #{instance.batch_number}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { client_batch_number: ['This mr delivery item batch already exists'] }))
    end

    def update_mr_delivery_item_batch(id, params)
      res = validate_mr_delivery_item_batch_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_delivery_item_batch(id, res)
        log_transaction
      end
      instance = mr_delivery_item_batch(id)
      success_response('Updated delivery item batch assignment', instance)
    end

    def delete_mr_delivery_item_batch(id)
      batch_number = mr_delivery_item_batch(id).batch_number
      repo.transaction do
        repo.delete_mr_delivery_item_batch(id)
        log_status('mr_delivery_item_batches', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted delivery item batch assignment to #{batch_number}")
    end
  end
end
