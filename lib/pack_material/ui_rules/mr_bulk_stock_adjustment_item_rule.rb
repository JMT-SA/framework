# frozen_string_literal: true

module UiRules
  class MrBulkStockAdjustmentItemRule < Base
    def generate_rules
      @repo = PackMaterialApp::TransactionsRepo.new
      make_form_object
      apply_form_values

      # common_values_for_fields @mode == :new ? new_fields : common_fields
      common_values_for_fields new_fields

      set_show_fields if @mode == :show

      form_name 'mr_bulk_stock_adjustment_item'
    end

    def set_show_fields
      fields[:mr_bulk_stock_adjustment_id] = { renderer: :hidden }
      fields[:mr_sku_location_id] = { renderer: :hidden }
      fields[:sku_number] = { renderer: :label }
      fields[:product_variant_number] = { renderer: :label }
      fields[:mr_type_name] = { renderer: :label, caption: 'Type Name' }
      fields[:mr_sub_type_name] = { renderer: :label, caption: 'Sub Type Name' }
      fields[:product_variant_code] = { renderer: :label }
      fields[:location_long_code] = { renderer: :label }
      fields[:inventory_uom_code] = { renderer: :label, caption: 'UOM Code' }
      fields[:scan_to_location_long_code] = { renderer: :label }
      fields[:system_quantity] = { renderer: :label }
      fields[:actual_quantity] = { renderer: :label }
      fields[:stock_take_complete] = { renderer: :label, as_boolean: true }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def new_fields
      {
        mr_bulk_stock_adjustment_id: { renderer: :hidden },
        sku_location_lookup: {
          renderer: :lookup,
          lookup_name: :sku_locations,
          lookup_key: :standard,
          caption: 'Select SKU Location',
          param_values: {
            allowed_sku_numbers: for_lookup_sku_number_options.map { |r| r[0] },
            allowed_locations: location_options.map { |r| r[1] }
          }
        },
        mr_sku_id: { renderer: :select, options: sku_number_options, caption: 'SKU Number' },
        location_id: { renderer: :select, options: location_options, caption: 'Location Code' },
        list_items: { renderer: :list, items: list_items, caption: 'List Items' }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_bulk_stock_adjustment_item(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_bulk_stock_adjustment_id: @options[:parent_id],
                                    mr_sku_location_id: nil,
                                    sku_number: sku_number_options.first,
                                    location_long_code: location_options.first,
                                    list_items: list_items)
    end

    def bulk_stock_adjustment_id
      @options[:parent_id] || @form_object.mr_bulk_stock_adjustment_id
    end

    def mr_sku_location_options
      options = @repo.for_select_mr_sku_locations(where: { mr_sku_id: @repo.bulk_stock_adjustment_sku_ids(bulk_stock_adjustment_id) })
      ['none'] + options
    end

    def sku_number_options
      @repo.bulk_stock_adjustment_sku_numbers(bulk_stock_adjustment_id)
    end

    def for_lookup_sku_number_options
      @repo.for_lookup_bulk_stock_adjustment_sku_numbers(bulk_stock_adjustment_id)
    end

    def location_options
      @repo.bulk_stock_adjustment_locations(bulk_stock_adjustment_id)
    end

    def list_items
      items = @repo.bulk_stock_adjustment_list_items(@options[:parent_id])
      items.map { |r| "#{r[:product_variant_code]} (SKU:#{r[:sku_number]}) (LOC:#{r[:location_long_code]})" }
    end
  end
end
