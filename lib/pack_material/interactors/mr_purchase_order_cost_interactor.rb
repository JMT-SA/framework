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

    def create_mr_purchase_order_cost(parent_id, params)
      params[:mr_purchase_order_id] = parent_id
      res = validate_mr_purchase_order_cost_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_mr_purchase_order_cost(res)
        log_status('mr_purchase_order_costs', id, 'CREATED')
        log_transaction
      end
      instance = mr_purchase_order_cost(id)
      success_response("Created mr purchase order cost #{instance.id}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { id: ['This mr purchase order cost already exists'] }))
    end

    def update_mr_purchase_order_cost(id, params)
      res = validate_mr_purchase_order_cost_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_purchase_order_cost(id, res)
        log_transaction
      end
      instance = mr_purchase_order_cost(id)
      success_response("Updated mr purchase order cost #{instance.id}",
                       instance)
    end

    def delete_mr_purchase_order_cost(id)
      name = mr_purchase_order_cost(id).id
      repo.transaction do
        repo.delete_mr_purchase_order_cost(id)
        log_status('mr_purchase_order_costs', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted mr purchase order cost #{name}")
    end

    def po_sub_totals(id)
      repo.sub_totals(id)
    end
  end
end
