# frozen_string_literal: true

module PackMaterialApp
  class MrPurchaseOrderItemInteractor < BaseInteractor
    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_purchase_order_item(id)
      repo.find_mr_purchase_order_item(id)
    end

    def validate_mr_purchase_order_item_params(params)
      MrPurchaseOrderItemSchema.call(params)
    end

    def create_mr_purchase_order_item(parent_id, params)
      params[:mr_purchase_order_id] = parent_id
      can_create = TaskPermissionCheck::MrPurchaseOrderItem.call(:create, purchase_order_id: parent_id)
      if can_create.success
        res = validate_mr_purchase_order_item_params(params)
        return validation_failed_response(res) unless res.messages.empty?
        id = nil
        repo.transaction do
          id = repo.create_mr_purchase_order_item(res)
          log_status('mr_purchase_order_items', id, 'CREATED')
          log_transaction
        end
        instance = mr_purchase_order_item(id)
        success_response("Created purchase order item #{instance.id}", instance)
      else
        failed_response(can_create.message)
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { id: ['This purchase order item already exists'] }))
    end

    def update_mr_purchase_order_item(id, params)
      can_update = TaskPermissionCheck::MrPurchaseOrderItem.call(:update, id)
      if can_update.success
        res = validate_mr_purchase_order_item_params(params)
        return validation_failed_response(res) unless res.messages.empty?
        repo.transaction do
          repo.update_mr_purchase_order_item(id, res)
          log_transaction
        end
        instance = mr_purchase_order_item(id)
        success_response("Updated purchase order item #{instance.id}", instance)
      else
        failed_response(can_update.message)
      end
    end

    def delete_mr_purchase_order_item(id)
      can_delete = TaskPermissionCheck::MrPurchaseOrderItem.call(:delete, id)
      if can_delete.success
        name = mr_purchase_order_item(id).id
        repo.transaction do
          repo.delete_mr_purchase_order_item(id)
          log_status('mr_purchase_order_items', id, 'DELETED')
          log_transaction
        end
        success_response("Deleted purchase order item #{name}")
      else
        failed_response(can_delete.message)
      end
    end

    def po_sub_totals(id = nil, parent_id: nil)
      if parent_id
        repo.sub_totals(parent_id)
      else
        repo.sub_totals(mr_purchase_order_item(id).mr_purchase_order_id)
      end
    end
  end
end
