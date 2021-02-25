# frozen_string_literal: true

module PackMaterialApp
  class MrSalesOrderInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
    def create_mr_sales_order(params) # rubocop:disable Metrics/AbcSize
      res = validate_new_mr_sales_order_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_mr_sales_order(res.to_h.merge(created_by: @user.user_name))
        log_status('mr_sales_orders', id, 'CREATED')
        log_transaction
      end
      success_response('Created Sales Order', id)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This Sales Order already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_sales_order(id, params)
      res = validate_mr_sales_order_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_mr_sales_order(id, res)
        log_status('mr_sales_orders', id, 'UPDATED')
        log_transaction
      end
      instance = mr_sales_order(id)
      success_response('Updated Sales Order', instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_sales_order(id)
      number = mr_sales_order(id).sales_order_number
      repo.transaction do
        repo.delete_mr_sales_order(id)
        log_status('mr_sales_orders', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted Sales Order #{number ? 'No: ' + number : ''}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def get_mrpv_info_with_so_id(id, mrpv_id)
      in_use = repo.exists?(:mr_sales_order_item, mr_sales_order_id: id, mr_product_variant_id: mrpv_id)
      return failed_response('Sales order item for Product Variant already exists') if in_use

      success_response('OK', repo.get_mrpv_info(mrpv_id))
    end

    def get_mrpv_info(mrpv_id)
      repo.get_mrpv_info(mrpv_id)
    end

    def ship_mr_sales_order(id) # rubocop:disable Metrics/AbcSize
      assert_permission!(:can_ship, id)
      repo.transaction do
        res = repo.validate_sales_stock_levels(id)
        return res unless res.success

        repo.update_with_document_number('doc_seqs_sales_order_number', id)
        so = repo.find_mr_sales_order(id)
        loc_id = so.dispatch_location_id
        issue_id = nil
        attrs = {
          business_process_id: repo.sales_order_business_process_id,
          user_name: @user.user_name,
          ref_no: so.sales_order_number
        }
        items = res.instance
        items.each do |item|
          attrs[:parent_transaction_id] = issue_id
          result = PackMaterialApp::RemoveMrStock.call(item[:sku_id], loc_id, item[:qty], attrs)
          transaction_item_id = result.instance
          issue_id ||= TransactionsRepo.new.find_mr_inventory_transaction_item(transaction_item_id)&.mr_inventory_transaction_id
        end
        repo.update(:mr_sales_orders, id, shipped: true, shipped_at: DateTime.now, issue_transaction_id: issue_id)
        log_status('mr_sales_orders', id, 'SHIPPED')
        log_transaction
      end
      number = mr_sales_order(id)&.sales_order_number
      success_response("Sales Order No: #{number} has been shipped")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def complete_invoice(id)
      assert_permission!(:integrate, id)
      repo.transaction do
        PackMaterialApp::CompleteSalesOrder.call(id, @user.user_name, false, nil)
        log_transaction
        instance = mr_sales_order(id)
        success_response("Sales Order #{instance.sales_order_number}: Sales Order Invoice Sent", instance)
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def assert_permission!(task, id = nil)
      res = check_permission(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_permission(task, id = nil)
      TaskPermissionCheck::MrSalesOrder.call(task, id, current_user: @user)
    end

    def email_sales_order_defaults(id, user)
      instance = mr_sales_order(id)
      party_repo = MasterfilesApp::PartyRepo.new
      customer_email = party_repo.email_address_for_party_role(instance.customer_party_role_id)
      {
        to: customer_email,
        cc: user.email,
        subject: "Sales Order #{instance.sales_order_number}"
      }
    end

    private

    def repo
      @repo ||= DispatchRepo.new
    end

    def mr_sales_order(id)
      repo.find_mr_sales_order(id)
    end

    def validate_mr_sales_order_params(params)
      MrSalesOrderSchema.call(params)
    end

    def validate_new_mr_sales_order_params(params)
      NewMrSalesOrderSchema.call(params)
    end

    # def already_enqueued?(grn_id)
    #   PackMaterialApp::ERPPurchaseInvoiceJob.enqueued_with_args?(mr_goods_returned_note_id: grn_id)
    # end
  end
end
