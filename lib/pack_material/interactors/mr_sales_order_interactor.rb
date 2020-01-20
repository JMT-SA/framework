# frozen_string_literal: true

module PackMaterialApp
  class MrSalesOrderInteractor < BaseInteractor
    def create_mr_sales_order(params) # rubocop:disable Metrics/AbcSize
      res = validate_new_mr_sales_order_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_mr_sales_order(res.to_h.merge(created_by: @user.user_name))
        log_status('mr_sales_orders', id, 'CREATED')
        log_transaction
      end
      instance = mr_sales_order(id)
      so_number = instance.sales_order_number
      success_response("Created Sales Order #{so_number ? 'No: ' + so_number : ''}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This Sales Order already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_sales_order(id, params) # rubocop:disable Metrics/AbcSize
      res = validate_mr_sales_order_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_mr_sales_order(id, res)
        log_status('mr_sales_orders', id, 'UPDATED')
        log_transaction
      end
      instance = mr_sales_order(id)
      so_number = instance.sales_order_number
      success_response("Updated Sales Order #{so_number ? 'No: ' + so_number : ''}", instance)
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
        attrs = {
          business_process_id: repo.sales_order_business_process_id,
          user_name: @user.user_name,
          parent_transaction_id: so.issue_transaction_id,
          ref_no: so.sales_order_number
        }
        items = res.instance
        items.each do |item|
          PackMaterialApp::RemoveMrStock.call(item[:sku_id], loc_id, item[:qty], attrs)
        end
        repo.update(:mr_sales_orders, id, shipped: true, shipped_at: DateTime.now)
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

    # def complete_invoice(id)
    #   assert_permission!(:complete_invoice, id)
    #   return success_response('GRN Purchase Invoice has already been Queued') if already_enqueued?(id)
    #
    #   repo.transaction do
    #     PackMaterialApp::CompletePurchaseInvoice.call(@user.user_name, false, nil, mr_goods_returned_note_id: id)
    #     log_transaction
    #     instance = mr_goods_returned_note(id)
    #     success_response("GRN #{instance.credit_note_number}: Purchase Invoice Queued", instance)
    #   end
    # rescue Crossbeams::InfoError => e
    #   failed_response(e.message)
    # end

    def assert_permission!(task, id = nil)
      res = check_permission(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_permission(task, id = nil)
      TaskPermissionCheck::MrSalesOrder.call(task, id, current_user: @user)
    end
    #
    # def email_credit_note_defaults(id, user)
    #   instance = mr_goods_returned_note(id)
    #   repo = DevelopmentApp::UserRepo.new
    #   email_addresses = repo.email_addresses(user_email_group: AppConst::GRN_MAIL_RECIPIENTS)
    #   {
    #     to: email_addresses.map { |r| r[1] }.uniq,
    #     cc: user.email,
    #     subject: "Credit Note: #{instance.credit_note_number}"
    #   }
    # end

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
