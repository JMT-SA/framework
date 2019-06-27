# frozen_string_literal: true

module PackMaterialApp
  class CreateMrStock < BaseService
    # @param [Object] sku_ids
    # @param [Object] business_process_id
    # @param [Hash] opts
    #   Contains quantities: [Array] of hashes { sku_id: sku_id, qty: qty }
    #                        Mandatory unless delivery_id present
    #   Contains location_long_code, delivery_id, ref_no, parent_transaction_id
    def initialize(sku_ids = [], business_process_id = nil, opts = {})
      @repo = MrStockRepo.new
      @transaction_repo = PackMaterialApp::TransactionsRepo.new
      @sku_ids = sku_ids
      @business_process_id = business_process_id
      @to_location_id = opts.fetch(:to_location_id)
      @delivery_id = opts[:delivery_id]
      @quantities = opts.fetch(:quantities) unless @delivery_id
      @ref_no = opts[:ref_no]
      @parent_transaction_id = opts[:parent_transaction_id]
      @opts = opts
    end

    def call
      return failed_response 'Stock can not be created without sku_ids' unless @sku_ids.any?

      res = @repo.create_sku_location_ids(@sku_ids, @to_location_id)
      return res unless res.success

      if @parent_transaction_id
        res = @repo.activate_mr_inventory_transaction(@parent_transaction_id)
        return res unless res.success
      else
        type_id = @repo.transaction_type_id_for('create')
        attrs = {
          mr_inventory_transaction_type_id: type_id,
          to_location_id: @to_location_id,
          business_process_id: @business_process_id,
          ref_no: @ref_no,
          active: true,
          is_adhoc: @delivery_id.nil?,
          created_by: @opts[:user_name]
        }
        @parent_transaction_id = @transaction_repo.create_mr_inventory_transaction(attrs)
      end

      if @delivery_id
        res = @repo.update_delivery_receipt_id(@delivery_id, @parent_transaction_id)
        return res unless res.success

        @quantities = @repo.get_delivery_sku_quantities(@delivery_id)
      end

      res = @repo.add_sku_location_quantities(@quantities, @to_location_id)
      return res unless res.success

      response_hash = {
        parent_transaction_id: @parent_transaction_id,
        transaction_item_ids: []
      }
      @quantities.each do |hsh|
        transaction_item_id = @transaction_repo.create_mr_inventory_transaction_item(
          mr_inventory_transaction_id: @parent_transaction_id,
          mr_sku_id: hsh[:sku_id],
          inventory_uom_id: @repo.sku_uom_id(hsh[:sku_id]),
          to_location_id: @to_location_id,
          quantity: hsh[:qty]
        )
        response_hash[:transaction_item_ids] << hsh.merge(transaction_item_id: transaction_item_id)
      end
      success_response('ok', response_hash)
    end
  end
end
