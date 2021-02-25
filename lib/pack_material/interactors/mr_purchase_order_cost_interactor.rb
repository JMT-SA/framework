# frozen_string_literal: true

module PackMaterialApp
  class MrPurchaseOrderCostInteractor < BaseInteractor
    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_purchase_order_cost(id)
      repo.find_mr_purchase_order_cost(id)
    end

    def validate_mr_purchase_order_cost_params(params)
      MrPurchaseOrderCostSchema.call(params)
    end

    def create_mr_purchase_order_cost(parent_id, params) # rubocop:disable Metrics/AbcSize
      params[:mr_purchase_order_id] = parent_id
      can_create = TaskPermissionCheck::MrPurchaseOrderCost.call(:create, purchase_order_id: parent_id)
      if can_create.success
        res = validate_mr_purchase_order_cost_params(params)
        return validation_failed_response(res) if res.failure?

        id = nil
        repo.transaction do
          id = repo.create_mr_purchase_order_cost(res)
          log_status('mr_purchase_order_costs', id, 'CREATED')
          log_transaction
        end
        instance = mr_purchase_order_cost(id)
        success_response("Created purchase order cost #{instance.id}", instance)
      else
        failed_response(can_create.message)
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { id: ['This purchase order cost already exists'] }))
    end

    def update_mr_purchase_order_cost(id, params)
      can_update = TaskPermissionCheck::MrPurchaseOrderCost.call(:update, id)
      if can_update.success
        res = validate_mr_purchase_order_cost_params(params)
        return validation_failed_response(res) if res.failure?

        repo.transaction do
          repo.update_mr_purchase_order_cost(id, res)
          log_transaction
        end
        instance = mr_purchase_order_cost(id)
        success_response("Updated purchase order cost #{instance.id}", instance)
      else
        failed_response(can_update.message)
      end
    end

    def delete_mr_purchase_order_cost(id)
      can_delete = TaskPermissionCheck::MrPurchaseOrderCost.call(:delete, id)
      if can_delete.success
        name = mr_purchase_order_cost(id).id
        repo.transaction do
          repo.delete_mr_purchase_order_cost(id)
          log_status('mr_purchase_order_costs', id, 'DELETED')
          log_transaction
        end
        success_response("Deleted purchase order cost #{name}")
      else
        failed_response(can_delete)
      end
    end

    def po_sub_totals(id)
      repo.po_sub_totals(id)
    end
  end
end
