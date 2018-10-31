# frozen_string_literal: true

module PackMaterialApp
  class MrPurchaseOrderInteractor < BaseInteractor
    def create_mr_purchase_order(params)
      res = validate_mr_purchase_order_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_mr_purchase_order(res)
        log_status('mr_purchase_orders', id, 'CREATED')
        log_transaction
      end
      instance = mr_purchase_order(id)
      success_response("Created purchase order #{instance.purchase_account_code}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { purchase_account_code: ['This purchase order already exists'] }))
    end

    def update_mr_purchase_order(id, params)
      res = validate_mr_purchase_order_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_purchase_order(id, res)
        log_transaction
      end
      instance = mr_purchase_order(id)
      success_response("Updated purchase order #{instance.purchase_account_code}", instance)
    end

    def approve_purchase_order(id)
      instance = mr_purchase_order(id)
      if instance.purchase_order_number
        failed_response('This purchase order has already been approved')
      else
        repo.transaction do
          log_status('mr_purchase_orders', id, 'APPROVED')
          repo.update_with_document_number('doc_seqs_po_number', id)
          log_transaction
        end
        success_response('Purchase Order Approved', instance)
      end
    end

    def delete_mr_purchase_order(id)
      name = mr_purchase_order(id).purchase_account_code
      repo.transaction do
        repo.delete_mr_purchase_order(id)
        log_status('mr_purchase_orders', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted purchase order #{name}")
    end

    def po_sub_totals(id)
      repo.sub_totals(id)
    end

    private

    def repo
      @repo ||= ReplenishRepo.new
    end

    def mr_purchase_order(id)
      repo.find_mr_purchase_order(id)
    end

    def validate_mr_purchase_order_params(params)
      MrPurchaseOrderSchema.call(params)
    end
  end
end
