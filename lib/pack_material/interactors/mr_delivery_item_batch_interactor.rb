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

    def create_mr_delivery_item_batch(parent_id, params) # rubocop:disable Metrics/AbcSize
      params[:mr_delivery_item_id] = parent_id
      can_create = TaskPermissionCheck::MrDeliveryItemBatch.call(:create, delivery_item_id: parent_id)
      if can_create.success
        res = validate_mr_delivery_item_batch_params(params)
        return validation_failed_response(res) unless res.messages.empty?
        id = nil
        repo.transaction do
          id = repo.create_mr_delivery_item_batch(res)
          log_status('mr_delivery_item_batches', id, 'CREATED')
          log_transaction
        end
        instance = mr_delivery_item_batch(id)
        success_response("Created mr delivery item batch #{instance.client_batch_number}", instance)
      else
        failed_response(can_create.message)
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { client_batch_number: ['This mr delivery item batch already exists'] }))
    end

    def update_mr_delivery_item_batch(id, params)
      can_update = TaskPermissionCheck::MrDeliveryItemBatch.call(:update, id)
      if can_update.success
        res = validate_mr_delivery_item_batch_params(params)
        return validation_failed_response(res) unless res.messages.empty?
        repo.transaction do
          repo.update_mr_delivery_item_batch(id, res)
          log_transaction
        end
        instance = mr_delivery_item_batch(id)
        success_response('Updated delivery item batch assignment', instance)
      else
        failed_response(can_update.message)
      end
    end

    def delete_mr_delivery_item_batch(id)
      can_delete = TaskPermissionCheck::MrDeliveryItemBatch.call(:delete, id)
      if can_delete.success
        batch_number = mr_delivery_item_batch(id).client_batch_number
        repo.transaction do
          repo.delete_mr_delivery_item_batch(id)
          log_status('mr_delivery_item_batches', id, 'DELETED')
          log_transaction
        end
        success_response("Deleted delivery item batch assignment to #{batch_number}")
      else
        failed_response(can_delete.message)
      end
    end

    def print_sku_barcode(id, params)
      instance = repo.sku_for_barcode(id)
      LabelPrintingApp::PrintLabel.call(AppConst::LABEL_SKU_BARCODE, instance, params)
    end
  end
end
