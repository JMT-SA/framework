# frozen_string_literal: true

module PackMaterialApp
  class MrInventoryTransactionInteractor < BaseInteractor
    def sku_location_transaction_history(sku_location_id)
      repo.sku_number_for_sku_location(id)
    end

    def create_adhoc_stock_transaction(id, params, type)
      attrs = {}
      attrs[:location_id] = replenish_repo.location_id_from_sku_location_id(id)
      attrs[:sku_ids] = replenish_repo.sku_ids_from_numbers([params[:sku_number]])
      return validation_failed_response(OpenStruct.new(messages: { sku_number: ['SKU number invalid'] })) unless attrs[:sku_ids].any?
      attrs[:user_name] = @user.user_name
      attrs = attrs.merge(params)
      attrs[:quantity] = params[:quantity].to_f
      instance = attrs[:sku_number]
      repo.transaction do
        case type
        when 'add'
          res = adhoc_add_stock(attrs)
          res = res.success ? success_response("Stock Added for SKU Number: #{instance}", instance) : res
        when 'move'
          res = adhoc_move_stock(attrs)
          res = res.success ? success_response("Stock Moved for SKU Number: #{instance}") : res
        when 'remove'
          res = adhoc_remove_stock(attrs)
          res = res.success ? success_response("Stock Removed for SKU Number: #{instance}") : res
        else
          res = failed_response('Adhoc Transaction Type invalid')
        end
        res
      end
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { ref_no: ['must be unique'] }))
    end

    def create_mr_inventory_transaction(params)
      res = validate_mr_inventory_transaction_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      id = nil
      repo.transaction do
        id = repo.create_mr_inventory_transaction(res)
        log_status('mr_inventory_transactions', id, 'CREATED')
        log_transaction
      end
      instance = mr_inventory_transaction(id)
      success_response("Created mr inventory transaction #{instance.created_by}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { created_by: ['This mr inventory transaction already exists'] }))
    end

    def update_mr_inventory_transaction(id, params)
      res = validate_mr_inventory_transaction_params(params)
      return validation_failed_response(res) unless res.messages.empty?
      repo.transaction do
        repo.update_mr_inventory_transaction(id, res)
        log_transaction
      end
      instance = mr_inventory_transaction(id)
      success_response("Updated mr inventory transaction #{instance.created_by}", instance)
    end

    def delete_mr_inventory_transaction(id)
      name = mr_inventory_transaction(id).created_by
      repo.transaction do
        repo.delete_mr_inventory_transaction(id)
        log_status('mr_inventory_transactions', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted mr inventory transaction #{name}")
    end

    private

    def repo
      @repo ||= TransactionsRepo.new
    end

    def replenish_repo
      @replenish_repo ||= ReplenishRepo.new
    end

    def mr_inventory_transaction(id)
      repo.find_mr_inventory_transaction(id)
    end

    def validate_mr_inventory_transaction_params(params)
      MrInventoryTransactionSchema.call(params)
    end

    def adhoc_add_stock(attrs)
      CreateMrStock.call(attrs[:sku_ids],
                         attrs[:business_process_id],
                         to_location_id: attrs[:location_id],
                         user_name: attrs[:user_name],
                         ref_no: attrs[:ref_no],
                         quantities: [{ sku_id: attrs[:sku_ids][0], qty: attrs[:quantity] }])
    end

    def adhoc_move_stock(attrs)
      MoveMrStock.call(attrs[:sku_ids][0],
                       attrs[:to_location_id],
                       attrs[:quantity],
                       is_adhoc: true,
                       ref_no: attrs[:ref_no],
                       business_process_id: attrs[:business_process_id],
                       user_name: attrs[:user_name],
                       from_location_id: attrs[:location_id])
    end

    def adhoc_remove_stock(attrs)
      RemoveMrStock.call(attrs[:sku_ids][0],
                         attrs[:location_id],
                         attrs[:quantity],
                         is_adhoc: true,
                         ref_no: attrs[:ref_no],
                         business_process_id: attrs[:business_process_id],
                         user_name: attrs[:user_name])
    end
  end
end
