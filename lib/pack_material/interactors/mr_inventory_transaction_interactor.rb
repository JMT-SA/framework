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

    def validation_for_adhoc_rmd_move_stock(params) # rubocop:disable Metrics/AbcSize
      from_location_id = replenish_repo.resolve_location_id_from_scan(params[:from_location], params[:from_location_scan_field])
      return validation_failed_response(from_location: params[:from_location], messages: { from_location: ['Location short code not found'] }) unless from_location_id

      existing_stock = existing_stock?(from_location_id, params[:sku_number])
      return validation_failed_response(from_location: params[:from_location], messages: { from_location: ["Location does not have existing stock for SKU:#{params[:sku_number]}"] }) unless existing_stock

      params[:from_location_id] = from_location_id
      params[:business_process_id] = repo.process_id(params[:business_process])

      res = validate_adhoc_rmd_move_stock_params(params)
      return validation_failed_response(res) unless res.messages.empty?

      success_response('OK', res)
    end

    def adhoc_rmd_move_stock(params) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      to_location_id = replenish_repo.resolve_location_id_from_scan(params[:to_location], params[:to_location_scan_field])
      return validation_failed_response(to_location: params[:to_location], messages: { to_location: ['Location short code not found'] }) unless to_location_id

      valid_stock_location = stock_repo.stock_location?(to_location_id)
      return validation_failed_response(to_location: params[:to_location], messages: { to_location: ['Location can not store stock'] }) unless valid_stock_location

      sku_ids = replenish_repo.sku_ids_from_numbers(params[:sku_number])
      delivery_number = replenish_repo.delivery_stock(sku_ids[0], params[:from_location_id])
      return validation_failed_response(to_location: params[:to_location], messages: { to_location: ["Delivery Stock (#{delivery_number}) can not be moved with adhoc transactions"] }) if delivery_number

      res = validate_final_adhoc_rmd_move_stock_params(params.merge(sku_ids: sku_ids,
                                                                    user_name: @user.user_name,
                                                                    to_location_id: to_location_id,
                                                                    location_id: params[:from_location_id]))
      return validation_failed_response(res) unless res.messages.empty?

      can_action = TaskPermissionCheck::MrInventoryTransaction.call(:move,
                                                                    sku_ids: sku_ids,
                                                                    loc_id: params[:from_location_id],
                                                                    move_loc_id: to_location_id)
      if can_action.success
        repo.transaction do
          log_transaction
          res = adhoc_move_stock(res)
          raise Crossbeams::InfoError, res.message unless res.success

          html_report = repo.html_adhoc_stock_move_report(res.instance)
          success_response('Successful adhoc stock move', OpenStruct.new(transaction_item_id: res.instance, report: html_report))
        end
      else
        failed_response(can_action.message)
      end
    rescue Crossbeams::InfoError => e
      failed_response(e.message)
    rescue Sequel::UniqueConstraintViolation => e
      failed_response(e.message)
    end

    def adhoc_move_business_processes
      DB[:business_processes].select_map(:process) - [AppConst::PROCESS_STOCK_TAKE_ON]
    end

    def existing_stock?(from_location_id, sku_number)
      return nil unless sku_number && from_location_id

      sku_id = repo.sku_id_for_sku_number(sku_number)
      repo.existing_sku_locations_for(sku_id, from_location_id).first
    end

    def recalculate_wa_costs
      WaCostRepo.new.calculate_wa_costs
    end

    def weighted_average_records_grid
      {
        columnDefs: records_column_definitions,
        rowDefs: WaCostRepo.new.weighted_average_cost_records
      }.to_json
    end

    private

    def records_column_definitions
      Crossbeams::DataGrid::ColumnDefiner.new.make_columns do |mk|
        mk.integer 'mr_product_variant_id', 'MRPV ID', width: 130
        mk.integer 'sku_number', nil, hide: true
        mk.integer 'sku_id', nil, hide: true
        mk.integer 'id', 'applicable_id', width: 130
        mk.numeric 'quantity', nil, width: 130
        mk.col 'type', nil, width: 130
        mk.numeric 'price', nil, width: 130
        mk.col 'created_at', nil, width: 180
      end
    end

    def repo
      @repo ||= TransactionsRepo.new
    end

    def replenish_repo
      @replenish_repo ||= ReplenishRepo.new
    end

    def stock_repo
      @stock_repo ||= MrStockRepo.new
    end

    def location_repo
      @location_repo ||= MasterfilesApp::LocationRepo.new
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

    def validate_adhoc_rmd_move_stock_params(params)
      AdhocRmdMoveStockSchema.call(params)
    end

    def validate_final_adhoc_rmd_move_stock_params(params)
      FinalAdhocRmdMoveStockSchema.call(params)
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
                         business_process_id: attrs[:business_process_id],
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
