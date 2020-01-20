# frozen_string_literal: true

module UiRules
  class MrSalesOrderItemRule < Base
    def generate_rules
      @repo = PackMaterialApp::DispatchRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      form_name 'mr_sales_order_item'
    end

    def common_fields
      {
        mr_sales_order_id: { renderer: :hidden },
        mr_product_variant_lookup: {
          renderer: :lookup,
          lookup_name: :mr_product_variants,
          lookup_key: :standard,
          caption: 'Select Product Variant',
          param_values: { sales_order_id: mr_sales_order_id }
        },
        mr_product_variant_id: { renderer: :hidden },
        mr_product_variant_code: { caption: 'PV Code', required: true },
        mr_product_variant_number: { caption: 'PV Number', required: true },
        quantity_required: { required: true },
        unit_price: { renderer: :numeric, required: true }
      }
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_mr_sales_order_item(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_sales_order_id: nil,
                                    mr_product_variant_lookup: nil,
                                    mr_product_variant_id: nil,
                                    mr_product_variant_code: nil,
                                    mr_product_variant_number: nil,
                                    remarks: nil,
                                    quantity_required: nil,
                                    unit_price: nil)
    end

    def mr_sales_order_id
      @options[:parent_id] || @form_object.mr_sales_order_id
    end

    # private

    # def add_approve_behaviours
    #   behaviours do |behaviour|
    #     behaviour.enable :reject_reason, when: :approve_action, changes_to: ['r']
    #   end
    # end
  end
end
