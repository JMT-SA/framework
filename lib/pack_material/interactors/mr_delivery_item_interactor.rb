# frozen_string_literal: true

module PackMaterialApp
  class MrDeliveryItemInteractor < BaseInteractor
    def create_mr_delivery_item(parent_id, params) # rubocop:disable Metrics/AbcSize
      params[:mr_delivery_id] = parent_id
      can_create = TaskPermissionCheck::MrDeliveryItem.call(:create, delivery_id: parent_id)
      if can_create.success
        res = validate_mr_delivery_item_params(params)
        return validation_failed_response(res) if res.failure?

        new_attrs = repo.prepare_delivery_item_quantities(res)
        res = validate_mr_delivery_item_params(new_attrs)
        return validation_failed_response(res) if res.failure?

        id = nil
        repo.transaction do
          id = repo.create_mr_delivery_item(res)
          log_status('mr_delivery_items', id, 'CREATED')
          log_transaction
        end
        instance = mr_delivery_item(id)
        success_response("Created delivery item #{instance.remarks}", instance)
      else
        failed_response(can_create.message)
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { remarks: ['This delivery item already exists.'] }))
    end

    def update_mr_delivery_item(id, params) # rubocop:disable Metrics/AbcSize
      can_update = TaskPermissionCheck::MrDeliveryItem.call(:update, id)
      if can_update.success
        res = validate_mr_delivery_item_params(params)
        return validation_failed_response(res) if res.failure?

        new_attrs = repo.prepare_delivery_item_quantities(res)
        res = validate_mr_delivery_item_params(new_attrs)
        return validation_failed_response(res) if res.failure?

        repo.transaction do
          repo.update_mr_delivery_item(id, res)
          log_transaction
        end
        instance = mr_delivery_item(id)
        success_response("Updated delivery item #{instance.remarks}", instance)
      else
        failed_response(can_update.message)
      end
    end

    def delete_mr_delivery_item(id)
      can_delete = TaskPermissionCheck::MrDeliveryItem.call(:delete, id)
      if can_delete.success
        name = mr_delivery_item(id).remarks
        repo.transaction do
          repo.delete_mr_delivery_item(id)
          log_status('mr_delivery_items', id, 'DELETED')
          log_transaction
        end
        success_response("Deleted delivery item #{name}")
      else
        failed_response(can_delete.message)
      end
    end

    def inline_update(id, params)
      repo.transaction do
        repo.inline_update_delivery_item(id, params)
        log_status('mr_delivery_items', id, 'INLINE ADJUSTMENT')
        log_transaction
      end
      success_response('Updated delivery item invoice unit price')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def available_purchase_order_items(purchase_order_id, delivery_id)
      repo.for_select_remaining_purchase_order_items(purchase_order_id, delivery_id)
    end

    def purchase_order_id_for_delivery_item(delivery_item_id)
      repo.purchase_order_id_for_delivery_item(delivery_item_id)
    end

    def prepare_delivery_item_quantities(params)
      res = validate_mr_delivery_item_quantity_params(params)
      return validation_failed_response(res) if res.failure?

      attrs = res.to_h.transform_keys { |k| k.to_s.delete_prefix('mr_delivery_item_').to_sym }
      success_response('ok', repo.prepare_delivery_item_quantities(attrs))
    end

    def can_complete_invoice(parent_id)
      TaskPermissionCheck::MrDelivery.call(:complete_invoice, parent_id)
    end

    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_delivery_item(id)
      repo.find_mr_delivery_item(id)
    end

    def validate_mr_delivery_item_params(params)
      # MrDeliveryItemSchema.call(params)
      contract = MrDeliveryItemContract.new
      contract.call(params)
    end

    def validate_mr_delivery_item_quantity_params(params)
      # MrDeliveryItemQuantitySchema.call(params)
      contract = MrDeliveryItemQuantityContract.new
      contract.call(params)
    end
  end
end
