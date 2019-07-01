# frozen_string_literal: true

module PackMaterialApp
  class MrInventoryTransactionInteractor < BaseInteractor # rubocop:disable Metrics/ClassLength
    def create_adhoc_stock_transaction(sku_location_id, params, type) # rubocop:disable Metrics/AbcSize
      res = validate_adhoc_transaction_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      res = prep_adhoc_transaction_params(sku_location_id, res)
      return res unless res.success

      can_action = TaskPermissionCheck::MrInventoryTransaction.call(type.to_sym,
                                                                    sku_ids: res.instance[:sku_ids],
                                                                    loc_id: res.instance[:location_id],
                                                                    move_loc_id: res.instance[:to_location_id])
      if can_action.success
        repo.transaction do
          opts = {
            'add' => { call: ->(attrs) { adhoc_add_stock(attrs) }, message: 'Stock Added for SKU Number: %s' },
            'move' => { call: ->(attrs) { adhoc_move_stock(attrs) }, message: 'Stock Moved for SKU Number: %s' },
            'remove' => { call: ->(attrs) { adhoc_remove_stock(attrs) }, message: 'Stock Removed for SKU Number: %s' }
          }
          resp = opts[type][:call]&.call(res.instance)
          return failed_response('Adhoc Transaction Type invalid') if resp.nil?

          success_response(format(opts[type][:message], res.instance[:sku_number]), res.instance[:sku_number])
        end
      else
        failed_response(can_action.message)
      end
    rescue Sequel::UniqueConstraintViolation => e
      failed_response(e.message)
    end

    def create_mr_inventory_transaction(params) # rubocop:disable Metrics/AbcSize
      res = validate_mr_inventory_transaction_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      id = nil
      repo.transaction do
        id = repo.create_mr_inventory_transaction(res)
        log_status('mr_inventory_transactions', id, 'CREATED')
        log_transaction
      end

      instance = mr_inventory_transaction(id)
      success_response("Created inventory transaction #{instance.created_by}", instance)
    rescue Sequel::UniqueConstraintViolation
      validation_failed_response(OpenStruct.new(messages: { created_by: ['This inventory transaction already exists'] }))
    end

    def update_mr_inventory_transaction(id, params)
      res = validate_mr_inventory_transaction_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      repo.transaction do
        repo.update_mr_inventory_transaction(id, res)
        log_transaction
      end

      instance = mr_inventory_transaction(id)
      success_response("Updated inventory transaction #{instance.created_by}", instance)
    end

    def delete_mr_inventory_transaction(id)
      name = mr_inventory_transaction(id).created_by
      repo.transaction do
        repo.delete_mr_inventory_transaction(id)
        log_status('mr_inventory_transactions', id, 'DELETED')
        log_transaction
      end
      success_response("Deleted inventory transaction #{name}")
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

    def validate_adhoc_transaction_params(params)
      AdhocTransactionSchema.call(params)
    end

    def prep_adhoc_transaction_params(sku_location_id, attrs) # rubocop:disable Metrics/AbcSize
      loc_id = replenish_repo.location_id_from_sku_location_id(sku_location_id)
      return validation_failed_response(OpenStruct.new(messages: { location: ['Location can not store stock'] })) unless replenish_repo.location_can_store_stock?(loc_id)
      return validation_failed_response(OpenStruct.new(messages: { ref_no: ['Reference Number already exists'] })) if replenish_repo.ref_no_already_exists?(attrs[:ref_no])

      sku_ids = replenish_repo.sku_ids_from_numbers([attrs[:sku_number]])
      return validation_failed_response(OpenStruct.new(messages: { sku_number: ['SKU number invalid'] })) unless sku_ids.any?

      success_response('', attrs.to_h.merge(location_id: loc_id, sku_ids: sku_ids, user_name: @user.user_name))
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
