# frozen_string_literal: true

module PackMaterialApp
  class MrPurchaseOrderInteractor < BaseInteractor
    def create_mr_purchase_order(params) # rubocop:disable Metrics/AbcSize
      assert_permission!(:create)
      res = validate_mr_purchase_order_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_mr_purchase_order(res)
        log_status('mr_purchase_orders', id, 'CREATED')
        log_transaction
      end
      instance = mr_purchase_order(id)
      success_response("Created purchase order #{instance.purchase_order_number}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { purchase_account_code: ['This purchase order already exists'] }))
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def update_mr_purchase_order(id, params) # rubocop:disable Metrics/AbcSize
      assert_permission!(:update, id)
      res = validate_mr_purchase_order_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_mr_purchase_order(id, res)
        log_transaction
      end
      instance = mr_purchase_order(id)
      success_response("Updated purchase order #{instance.purchase_order_number}", instance)
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def approve_purchase_order(id)
      assert_permission!(:approve, id)
      instance = mr_purchase_order(id)
      repo.transaction do
        repo.update(:mr_purchase_orders, id, approved: true)
        log_status('mr_purchase_orders', id, 'APPROVED')
        repo.update_with_document_number('doc_seqs_po_number', id) unless instance.purchase_order_number
        log_transaction
      end
      success_response('Purchase Order Approved', instance)
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def short_supplied_purchase_order(id)
      assert_permission!(:short_supplied, id)
      repo.transaction do
        repo.update(:mr_purchase_orders, id, deliveries_received: true, short_supplied: true)
        log_status('mr_purchase_orders', id, 'SHORT SUPPLIED')
        log_transaction
      end
      success_response('Purchase Order Short Supplied and Completed', mr_purchase_order(id))
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def delete_mr_purchase_order(id)
      assert_permission!(:delete, id)
      name = mr_purchase_order(id).purchase_order_number
      repo.transaction do
        repo.delete_mr_purchase_order(id)
        log_status('mr_purchase_orders', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted purchase order #{name}")
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def po_sub_totals(id)
      repo.po_sub_totals(id)
    end

    def email_purchase_order_defaults(id, user)
      instance = mr_purchase_order(id)
      party_repo = MasterfilesApp::PartyRepo.new
      supplier_email = party_repo.email_address_for_party_role(instance.supplier_party_role_id)
      {
        to: supplier_email,
        cc: user.email,
        subject: "Purchase order #{instance.purchase_order_number}"
      }
    end

    def assert_permission!(task, id = nil)
      res = check_permission(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_permission(task, id = nil)
      TaskPermissionCheck::MrPurchaseOrder.call(task, id, @user)
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
