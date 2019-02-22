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
      MrBulkStockAdjustmentItemSchema.call(params)
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
      success_response("Created bulk stock adjustment item #{instance.mr_type_name}",
                       instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { mr_type_name: ['This bulk stock adjustment item already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_bulk_stock_adjustment_item(id, params)
      res = validate_mr_bulk_stock_adjustment_item_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_bulk_stock_adjustment_item(id, res)
        log_transaction
      end
      instance = mr_bulk_stock_adjustment_item(id)
      success_response("Updated bulk stock adjustment item #{instance.mr_type_name}",
                       instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_bulk_stock_adjustment_item(id)
      name = mr_bulk_stock_adjustment_item(id).mr_type_name
      repo.transaction do
        repo.delete_mr_bulk_stock_adjustment_item(id)
        log_status('mr_bulk_stock_adjustment_items', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted bulk stock adjustment item #{name}")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def complete_a_mr_bulk_stock_adjustment_item(id, params)
      res = complete_a_record(:mr_bulk_stock_adjustment_items, id, params.merge(enqueue_job: false))
      if res.success
        success_response(res.message, mr_bulk_stock_adjustment_item(id))
      else
        failed_response(res.message, mr_bulk_stock_adjustment_item(id))
      end
    end

    def reopen_a_mr_bulk_stock_adjustment_item(id, params)
      res = reopen_a_record(:mr_bulk_stock_adjustment_items, id, params.merge(enqueue_job: false))
      if res.success
        success_response(res.message, mr_bulk_stock_adjustment_item(id))
      else
        failed_response(res.message, mr_bulk_stock_adjustment_item(id))
      end
    end

    def approve_or_reject_a_mr_bulk_stock_adjustment_item(id, params)
      res = if params[:approve_action] == 'a'
              approve_a_record(:mr_bulk_stock_adjustment_items, id, params.merge(enqueue_job: false))
            else
              reject_a_record(:mr_bulk_stock_adjustment_items, id, params.merge(enqueue_job: false))
            end
      if res.success
        success_response(res.message, mr_bulk_stock_adjustment_item(id))
      else
        failed_response(res.message, mr_bulk_stock_adjustment_item(id))
      end
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::MrBulkStockAdjustmentItem.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end
  end
end
