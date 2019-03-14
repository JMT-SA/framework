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

    def validate_stock_item_adjust_params(params)
      ItemAdjustMrBulkStockAdjustmentSchema.call(params)
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
      success_response('Created bulk stock adjustment', instance)
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
      success_response('Updated bulk stock adjustment', instance)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def delete_mr_bulk_stock_adjustment(id)
      assert_permission!(:delete, id)
      repo.transaction do
        repo.delete_mr_bulk_stock_adjustment(id)
        log_status('mr_bulk_stock_adjustments', id, 'DELETED')
        log_transaction
      end
      success_response('Deleted bulk stock adjustment')
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

    def get_sku_location_info_ids(sku_location_id)
      repo.get_sku_location_info_ids(sku_location_id)
    end

    def complete_bulk_stock_adjustment(id)
      assert_permission!(:complete, id)
      repo.transaction do
        repo.complete_mr_bulk_stock_adjustment(id)
        log_transaction
        log_status('mr_bulk_stock_adjustments', id, 'COMPLETED')
        instance = mr_bulk_stock_adjustment(id)
        success_response('Completed Bulk Stock Adjustment', instance)
      end
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def reopen_bulk_stock_adjustment(id)
      assert_permission!(:reopen, id)
      repo.transaction do
        repo.reopen_mr_bulk_stock_adjustment(id)
        log_transaction
        log_status('mr_bulk_stock_adjustments', id, 'REOPENED')
        instance = mr_bulk_stock_adjustment(id)
        success_response('Reopened Bulk Stock Adjustment', instance)
      end
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    end

    def approve_bulk_stock_adjustment(id)
      assert_permission!(:approve, id)
      repo.transaction do
        log_transaction

        res = PackMaterialApp::BulkStockAdjustment.call(id, nil, user_name: @user.user_name)
        raise Crossbeams::InfoError#, res.message unless res.success

        log_status('mr_bulk_stock_adjustments', id, 'APPROVED')
        instance = mr_bulk_stock_adjustment(id)
        success_response('Approved Bulk Stock Adjustment', instance)
      end
    rescue Crossbeams::TaskNotPermittedError => e
      failed_response(e.message)
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def stock_item_adjust(params)
      bulk_stock_adjustment_id = repo.bulk_stock_adjustment_id_from_number(params[:stock_adjustment_number])
      can_adjust_stock = TaskPermissionCheck::MrBulkStockAdjustment.call(:adjust_stock, bulk_stock_adjustment_id)
      if can_adjust_stock.success
        res = validate_stock_item_adjust_params(params)
        return validation_failed_response(res) unless res.messages.empty?

        sku_ids = replenish_repo.sku_ids_from_numbers(params[:sku_number])
        sku_id = sku_ids[0]
        qty = Integer(params[:quantity])

        location_id = replenish_repo.resolve_location_id_from_scan(params[:location], params[:location_scan_field])
        location_id = Integer(location_id)

        opts = { user_name: @user.user_name, bulk_stock_adjustment_id: bulk_stock_adjustment_id }

        repo.transaction do
          log_transaction
          res = repo.rmd_update_bulk_stock_adjustment_item(
            mr_sku_id: sku_id,
            actual_quantity: qty,
            location_id: location_id,
            mr_bulk_stock_adjustment_id: bulk_stock_adjustment_id
          )
          raise Crossbeams::InfoError, res.message unless res.success

          log_status('mr_bulk_stock_adjustments', bulk_stock_adjustment_id, 'ADJUSTMENT REGISTERED')
          html_report = repo.html_stock_adjustment_progress_report(bulk_stock_adjustment_id, sku_id, location_id)
          success_response('Successful stock adjustment', OpenStruct.new(bulk_stock_adjustment_id: bulk_stock_adjustment_id, report: html_report))
        end
      else
        failed_response(can_adjust_stock.message)
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    end

    def replenish_repo
      ReplenishRepo.new
    end

    def assert_permission!(task, id = nil)
      res = TaskPermissionCheck::MrBulkStockAdjustment.call(task, id)
      raise Crossbeams::TaskNotPermittedError, res.message unless res.success
    end
  end
end
