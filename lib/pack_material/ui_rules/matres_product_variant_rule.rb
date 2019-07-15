# frozen_string_literal: true

module UiRules
  class MatresProductVariantRule < Base
    def generate_rules
      @repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      form_name 'matres_product_variant'
    end

    def common_fields
      {
        product_variant_id: { renderer: :hidden },
        product_variant_table_name: { renderer: :hidden, required: true },
        product_variant_number: { renderer: :label, required: true },
        old_product_code: {},
        supplier_lead_time: { renderer: :integer, caption: 'Lead Time (days)' },
        current_price: { renderer: :label },
        stock_adj_price: { renderer: :label },
        minimum_stock_level: { renderer: :integer },
        re_order_stock_level: { renderer: :integer },
        use_fixed_batch_number: { renderer: :checkbox },
        mr_internal_batch_number_id: { renderer: :select, options: @repo.for_select_mr_internal_batch_numbers, caption: 'Internal Batch Number', prompt: true }
      }
    end

    def make_form_object
      @form_object = @repo.find_matres_product_variant(@options[:id])
    end
  end
end
