# frozen_string_literal: true

module PackMaterialApp
  class MrSalesReturnItemInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
    def create_mr_sales_return_item(parent_id, params)  # rubocop:disable Metrics/AbcSize
      params[:mr_sales_return_id] = parent_id

      res = validate_mr_sales_return_item_params(params)
      return validation_failed_response(res) if res.failure?

      id = nil
      repo.transaction do
        id = repo.create_mr_sales_return_item(res)
        log_status(:mr_sales_return_items, id, 'CREATED')
        log_transaction
      end
      instance = mr_sales_return_item(id)
      success_response("Created sales return item #{instance.sales_return_number}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This sales return item already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_sales_return_item(id, params)
      res = validate_mr_sales_return_item_params(params)
      return validation_failed_response(res) if res.failure?

      repo.transaction do
        repo.update_mr_sales_return_item(id, res)
        log_transaction
      end
      instance = mr_sales_return_item(id)
      success_response("Updated sales return item #{instance.sales_return_number}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_sales_return_item(id)
      number = mr_sales_return_item(id).sales_return_number
      repo.transaction do
        repo.delete_mr_sales_return_item(id)
        log_status(:mr_sales_return_items, id, 'DELETED')
        log_transaction
      end
      success_response("Deleted sales return item #{number}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def inline_update(id, params) # rubocop:disable Metrics/AbcSize
      remarks = params[:column_name] == 'remarks'
      res = remarks ? validate_inline_update_remarks_params(params) : validate_inline_update_quantity_params(params)
      return validation_failed_response(res) if res.failure?

      unless remarks
        result = validate_sales_return_quantity_amount(id, params)
        return result unless result.success
      end

      repo.transaction do
        repo.inline_update_sales_return_items(id, res)
        log_status('mr_sales_return_items', id, 'INLINE ADJUSTMENT')
        log_transaction
      end
      success_response('Updated Sales Return Item')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def print_sku_barcode(params)
      res = validate_print_sku_barcode_params(params)
      return validation_failed_response(res) if res.failure?

      LabelPrintingApp::PrintLabel.call(AppConst::LABEL_SKU_BARCODE, res.to_h.merge(delivery_number: res[:sales_return_number]), res.to_h.merge(supporting_data: nil))
    end

    def assert_permission!(task, id = nil, sales_return_id: nil)
      res = check_permission(task, id, sales_return_id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def check_permission(task, id = nil, sales_return_id = nil)
      TaskPermissionCheck::MrSalesReturnItem.call(task, id, sales_return_id)
    end

    def check_parent_permission(task, id = nil)
      TaskPermissionCheck::MrSalesReturn.call(task, id, current_user: @user)
    end

    def allowed_options(parent_id)
      repo.sales_returns_item_options(parent_id)
    end

    def verify_sales_return(parent_id)
      check_parent_permission(:verify_sales_return, parent_id)
    end

    def mr_sales_return_item(id)
      repo.find_mr_sales_return_item(id)
    end

    def sales_return_sub_totals(sales_return_id)
      repo.sales_return_sub_totals(sales_return_id)
    end

    private

    def repo
      @repo ||= SalesReturnRepo.new
    end

    def dispatch_repo
      @dispatch_repo ||= DispatchRepo.new
    end

    def validate_mr_sales_return_item_params(params)
      MrSalesReturnItemSchema.call(params)
    end

    def validate_inline_update_quantity_params(params)
      MrSalesReturnItemInlineQuantitySchema.call(params)
    end

    def validate_sales_return_quantity_amount(id, params)
      repo.validate_sales_return_quantity_amount(id, params)
    end

    def validate_inline_update_remarks_params(params)
      MrSalesReturnItemInlineRemarksSchema.call(params)
    end

    def validate_print_sku_barcode_params(params)
      MrSalesReturnItemPrintSKUBarcodeSchema.call(params)
    end
  end
end
