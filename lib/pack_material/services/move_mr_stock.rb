# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize

module PackMaterialApp
  class MoveMrStock < BaseService
    # @param [Object] sku_id Only one sku per move
    # @param [Integer] to_location_id
    # @param [Numeric] quantity, Numeric(7,2)
    # @param [Hash] opts { :delivery_id, :tripsheet_id, :is_adhoc, :business_process_id, :from_location_id, :user_name }
    def initialize(sku_id, to_location_id, quantity, opts = {})
      @repo = MrStockRepo.new
      @transaction_repo = PackMaterialApp::TransactionsRepo.new
      @to_location_id = to_location_id
      @quantity = quantity
      @sku_id = sku_id
      @opts = opts

      @from_location_id = opts.fetch(:from_location_id, nil)
      @from_location_id = @repo.default_receiving_bay_id if @opts[:delivery_id]

      @parent_transaction_id = @repo.resolve_parent_transaction_id(@opts)
      @business_process_id = @repo.resolve_business_process_id(@opts)
    end

    def call
      return failed_response('To location does not exist') unless @repo.find_hash(:locations, @to_location_id)
      return failed_response('From location does not exist') unless @from_location_id && @repo.find_hash(:locations, @from_location_id)

      unless @parent_transaction_id
        type_id = @opts[:is_adhoc] ? @repo.transaction_type_id_for('adhoc') : @repo.transaction_type_id_for('putaway')
        attrs = {
          mr_inventory_transaction_type_id: type_id,
          to_location_id: @opts[:to_location_id],
          business_process_id: @business_process_id,
          ref_no: @opts[:ref_no],
          is_adhoc: (@opts[:is_adhoc] || false),
          created_by: @opts[:user_name]
        }
        @parent_transaction_id = @transaction_repo.create_mr_inventory_transaction(attrs)

        @repo.update_delivery_receipt_id(@opts[:delivery_id], @parent_transaction_id) if @opts[:delivery_id]
        # @repo.update_vehicle_job_transaction_id(@tripsheet_id, @parent_transaction_id) if @opts[:tripsheet_id] #vehicle_job.material_resource_inventory_transaction_id
      end

      @repo.create_sku_location_ids([@sku_id], @to_location_id)
      @repo.update_sku_location_quantity(@sku_id, @quantity, @from_location_id, add: false)
      @repo.update_sku_location_quantity(@sku_id, @quantity, @to_location_id, add: true)

      @transaction_repo.create_mr_inventory_transaction_item(
        mr_inventory_transaction_id: @parent_transaction_id,
        mr_sku_id: @sku_id,
        inventory_uom_id: @repo.sku_uom_id(@sku_id),
        quantity: @quantity
      )
      success_response('ok')
    end
  end
end