# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class RemoveMrStock < BaseService
    # @param [Object] sku_id Only one sku per remove
    # @param [Integer] location_id
    # @param [Numeric] quantity, Numeric(7,2)
    # @param [Hash] opts { :is_adhoc, :business_process_id, :user_name, :parent_transaction_id, :ref_no }
    def initialize(sku_id, location_id, quantity, opts = {})
      @repo = MrStockRepo.new
      @transaction_repo = PackMaterialApp::TransactionsRepo.new
      @location_id = location_id
      @quantity = quantity
      @sku_id = sku_id
      @opts = opts
      @parent_transaction_id = opts[:parent_transaction_id]
      @business_process_id = opts[:business_process_id]
    end

    def call
      return failed_response('SKU location does not exist') unless @repo.find_hash(:locations, @location_id)

      res = @repo.update_sku_location_quantity(@sku_id, @quantity, @location_id, add: false)
      return res unless res.success

      if @parent_transaction_id
        @repo.activate_mr_inventory_transaction(@parent_transaction_id)
      else
        attrs = {
          mr_inventory_transaction_type_id: @repo.transaction_type_id_for('destroy'),
          to_location_id: nil,
          business_process_id: @business_process_id,
          ref_no: @opts[:ref_no],
          active: true,
          is_adhoc: (@opts[:is_adhoc] || false),
          created_by: @opts[:user_name]
        }
        @parent_transaction_id = @transaction_repo.create_mr_inventory_transaction(attrs)
      end

      transaction_item_id = @transaction_repo.create_mr_inventory_transaction_item(
        mr_inventory_transaction_id: @parent_transaction_id,
        from_location_id: @location_id,
        mr_sku_id: @sku_id,
        inventory_uom_id: @repo.sku_uom_id(@sku_id),
        quantity: @quantity
      )
      success_response('ok', transaction_item_id)
    end
  end
end
