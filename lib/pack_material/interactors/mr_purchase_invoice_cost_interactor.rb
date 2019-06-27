# frozen_string_literal: true

module PackMaterialApp
  class MrPurchaseInvoiceCostInteractor < BaseInteractor
    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_purchase_invoice_cost(id)
      repo.find_mr_purchase_invoice_cost(id)
    end

    def validate_mr_purchase_invoice_cost_params(params)
      MrPurchaseInvoiceCostSchema.call(params)
    end

    def create_mr_purchase_invoice_cost(parent_id, params)
      params[:mr_delivery_id] = parent_id
      res = validate_mr_purchase_invoice_cost_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_mr_purchase_invoice_cost(res)
        log_status('mr_purchase_invoice_costs', id, 'CREATED')
        log_transaction
      end
      instance = mr_purchase_invoice_cost(id)
      success_response("Created purchase invoice cost #{instance.id}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { id: ['This purchase invoice cost already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_purchase_invoice_cost(id, params)
      res = validate_mr_purchase_invoice_cost_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_mr_purchase_invoice_cost(id, res)
        log_transaction
      end
      instance = mr_purchase_invoice_cost(id)
      success_response("Updated purchase invoice cost #{instance.id}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_purchase_invoice_cost(id)
      name = mr_purchase_invoice_cost(id).id
      repo.transaction do
        repo.delete_mr_purchase_invoice_cost(id)
        log_status('mr_purchase_invoice_costs', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted purchase invoice cost #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end
  end
end
