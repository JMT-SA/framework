# frozen_string_literal: true

module UiRules
  class MatresProductVariantRule < Base
    def generate_rules
      @repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'matres_product_variant'
    end

    def set_show_fields
      fields[:product_variant_id] = { renderer: :label }
      fields[:product_variant_table_name] = { renderer: :label }
      fields[:product_variant_number] = { renderer: :label }
      fields[:old_product_code] = { renderer: :label }
      fields[:supplier_lead_time] = { renderer: :label }
      fields[:minimum_stock_level] = { renderer: :label }
      fields[:re_order_stock_level] = { renderer: :label }
    end

    def common_fields
      {
        product_variant_id: { renderer: :hidden },
        product_variant_table_name: { renderer: :hidden, required: true },
        product_variant_number: { renderer: :label, required: true },
        old_product_code: {},
        supplier_lead_time: { caption: 'Lead Time (days)' },
        minimum_stock_level: {},
        re_order_stock_level: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_matres_product_variant(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(product_variant_id: nil,
                                    product_variant_table_name: nil,
                                    product_variant_number: nil,
                                    old_product_code: nil,
                                    supplier_lead_time: nil,
                                    minimum_stock_level: nil,
                                    re_order_stock_level: nil)
    end
  end
end
