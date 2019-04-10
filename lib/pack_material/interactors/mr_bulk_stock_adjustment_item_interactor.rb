# frozen_string_literal: true

module PackMaterialApp
  class MrBulkStockAdjustmentItemInteractor < BaseInteractor
    def repo
      @repo ||= TransactionsRepo.new
    end

    def mr_bulk_stock_adjustment_item(id)
      repo.find_mr_bulk_stock_adjustment_item(id)
    end

    def validate_mr_bulk_stock_adjustment_item_params(params)
      NewMrBulkStockAdjustmentItemSchema.call(params)
    end

    def validate_mr_bulk_stock_adjustment_item_update_params(params)
      UpdateMrBulkStockAdjustmentItemSchema.call(params)
    end

    def create_mr_bulk_stock_adjustment_item(parent_id, params)
      params[:mr_bulk_stock_adjustment_id] = parent_id
      res = validate_mr_bulk_stock_adjustment_item_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_mr_bulk_stock_adjustment_item(res)
        log_status('mr_bulk_stock_adjustment_items', id, 'CREATED')
        log_transaction
      end
      instance = mr_bulk_stock_adjustment_item(id)
      success_response("Created bulk stock adjustment item, SKU Number: #{instance.sku_number}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This bulk stock adjustment item already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_bulk_stock_adjustment_item(id, params)
      res = validate_mr_bulk_stock_adjustment_item_update_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_bulk_stock_adjustment_item(id, res)
        log_transaction
      end
      instance = mr_bulk_stock_adjustment_item(id)
      success_response("Updated bulk stock adjustment item #{instance.sku_number}", instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_bulk_stock_adjustment_item(id)
      name = mr_bulk_stock_adjustment_item(id).sku_number
      repo.transaction do
        repo.delete_mr_bulk_stock_adjustment_item(id)
        log_status('mr_bulk_stock_adjustment_items', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted bulk stock adjustment item #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def inline_update(id, params)
      repo.transaction do
        repo.inline_update_bulk_stock_adjustment_item(id, params)
        log_status('mr_bulk_stock_adjustment_items', id, 'INLINE ADJUSTMENT')
        log_transaction
      end
      success_response('Updated bulk stock adjustment item')
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def list_items(bulk_stock_adjustment_id)
      items = repo.bulk_stock_adjustment_list_items(bulk_stock_adjustment_id)
      items.map { |r| "#{r[:product_variant_code]} (SKU:#{r[:sku_number]}) (LOC:#{r[:location_long_code]})" }
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::MrBulkStockAdjustmentItem.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end

    def can_complete(parent_id)
      TaskPermissionCheck::MrBulkStockAdjustment.call(:complete, parent_id)
    end
  end
end
