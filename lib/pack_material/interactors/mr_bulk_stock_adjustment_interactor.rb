# frozen_string_literal: true

module PackMaterialApp
  class MrBulkStockAdjustmentInteractor < BaseInteractor
    def repo
      @repo ||= TransactionsRepo.new
    end

    def mr_bulk_stock_adjustment(id)
      repo.find_mr_bulk_stock_adjustment(id)
    end

    def validate_mr_bulk_stock_adjustment_params(params)
      NewBulkStockAdjustmentSchema.call(params)
    end

    def create_mr_bulk_stock_adjustment(params)
      res = validate_mr_bulk_stock_adjustment_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      attrs = res.to_h
      repo.transaction do
        id = repo.create_mr_bulk_stock_adjustment(attrs.merge(user_name: @user.user_name))
        log_status('mr_bulk_stock_adjustments', id, 'CREATED')
        log_status('mr_bulk_stock_adjustments', id, 'EDITING')
        log_transaction
      end
      instance = mr_bulk_stock_adjustment(id)
      success_response("Created bulk stock adjustment", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { base: ['This bulk stock adjustment already exists'] }))
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def update_mr_bulk_stock_adjustment(id, params)
      res = validate_mr_bulk_stock_adjustment_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_bulk_stock_adjustment(id, res)
        log_transaction
      end
      instance = mr_bulk_stock_adjustment(id)
      success_response("Updated bulk stock adjustment", instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_bulk_stock_adjustment(id)
      repo.transaction do
        repo.delete_mr_bulk_stock_adjustment(id)
        log_status('mr_bulk_stock_adjustments', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted bulk stock adjustment")
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def link_mr_skus(id, mr_sku_ids)
      repo.transaction do
        repo.link_mr_skus(id, mr_sku_ids)
      end
      success_response('SKUs linked successfully')
    end

    def link_locations(id, location_ids)
      repo.transaction do
        repo.link_locations(id, location_ids)
      end
      success_response('Locations linked successfully')
    end

    def complete_a_mr_bulk_stock_adjustment(id, params)
      res = complete_a_record(:mr_bulk_stock_adjustments, id, params.merge(enqueue_job: false))
      if res.success
        success_response(res.message, mr_bulk_stock_adjustment(id))
      else
        failed_response(res.message, mr_bulk_stock_adjustment(id))
      end
    end
    #
    # def reopen_a_mr_bulk_stock_adjustment(id, params)
    #   res = reopen_a_record(:mr_bulk_stock_adjustments, id, params.merge(enqueue_job: false))
    #   if res.success
    #     success_response(res.message, mr_bulk_stock_adjustment(id))
    #   else
    #     failed_response(res.message, mr_bulk_stock_adjustment(id))
    #   end
    # end

    def approve_or_reject_a_mr_bulk_stock_adjustment(id, params)
      res = if params[:approve_action] == 'a'
              approve_a_record(:mr_bulk_stock_adjustments, id, params.merge(enqueue_job: false))
            else
              reject_a_record(:mr_bulk_stock_adjustments, id, params.merge(enqueue_job: false))
            end
      if res.success
        success_response(res.message, mr_bulk_stock_adjustment(id))
      else
        failed_response(res.message, mr_bulk_stock_adjustment(id))
      end
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::MrBulkStockAdjustment.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end
  end
end
