# frozen_string_literal: true

module UiRules
  class MrInventoryTransactionRule < Base
    def generate_rules
      @repo = PackMaterialApp::TransactionsRepo.new
      @stock_repo = PackMaterialApp::MrStockRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields case @mode
                               when :new
                                 @options[:type] == 'move' ? stock_fields.merge(move_fields) : stock_fields
                               end

      @rules[:sku_number] = sku_number if @mode == :edit

      form_name 'mr_inventory_transaction'
    end

    def stock_fields
      {
        sku_number: { required: true },
        business_process_id: { renderer: :select, options: @stock_repo.for_select_business_processes, caption: 'Business Process', required: true },
        to_location_id: { renderer: :hidden },
        vehicle_id: { renderer: :hidden },
        ref_no: {},
        quantity: { renderer: :numeric, required: true },
        is_adhoc: { renderer: :hidden }
      }
    end

    def move_fields
      {
        to_location_id: { renderer: :select, options: @repo.allowed_locations, caption: 'Move to', required: true },
        vehicle_id: { renderer: :select, options: [], caption: 'Vehicle' }
      }
    end

    def make_form_object
      make_stock_form_object && return if %w[add move remove].include?(@options[:type])

      @form_object = @repo.find_mr_inventory_transaction(@options[:id])
    end

    def make_stock_form_object
      @form_object = OpenStruct.new(business_process_id: nil,
                                    sku_number:          sku_number,
                                    quantity:            0,
                                    ref_no:              nil,
                                    to_location_id:      nil,
                                    vehicle_id:          nil,
                                    is_adhoc:            true)
    end

    def sku_number
      @repo.sku_number_for_sku_location(@options[:sku_location_id])
    end
  end
end
