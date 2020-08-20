# frozen_string_literal: true

module UiRules
  class MrSalesReturnItemRule < Base
    def generate_rules
      @repo = PackMaterialApp::SalesReturnRepo.new
      @print_repo = LabelApp::PrinterRepo.new
      make_form_object
      apply_form_values

      rules[:zero_options] = allowed_options.none? if @mode == :new
      common_values_for_fields case @mode
                               when :new
                                 new_fields
                               when :print_barcode
                                 set_print_fields
                               else
                                 common_fields
                               end

      form_name 'mr_sales_return_item'
    end

    def new_fields
      {
        mr_sales_order_item_id: { renderer: :select,
                                  options: allowed_options,
                                  caption: 'Sales Order Item',
                                  required: true }
      }
    end

    def common_fields
      {
        mr_sales_return_id: { renderer: :hidden },
        mr_sales_order_item_id: { renderer: :hidden },
        remarks: {},
        quantity_returned: {}
      }
    end

    def set_print_fields
      {
        mr_sales_return_item_id: { renderer: :hidden },
        sales_return_number_label: { renderer: :label,
                                     with_value: @form_object.sales_return_number,
                                     caption: 'Sales Return Number' },
        sales_return_number: { renderer: :hidden },
        sku_id: { renderer: :hidden },
        sku_number_label: { renderer: :label,
                            with_value: @form_object.sku_number,
                            caption: 'SKU Number'  },
        sku_number: { renderer: :hidden },
        product_variant_code_label: { renderer: :label,
                                      with_value: @form_object.product_variant_code,
                                      caption: 'Product Variant Code'  },
        product_variant_code: { renderer: :hidden },
        product_variant_number: { renderer: :hidden },
        batch_number_label: { renderer: :label,
                              with_value: @form_object.batch_number,
                              caption: 'Batch Number'  },
        batch_number: { renderer: :hidden },
        printer: { renderer: :select,
                   options: @print_repo.select_printers_for_application(AppConst::PRINT_APP_MR_SKU_BARCODE),
                   required: true },
        no_of_prints: { renderer: :integer,
                        required: true }
      }
    end

    def make_form_object
      @form_object = if @mode == :new
                       OpenStruct.new(mr_sales_return_id: nil,
                                      mr_sales_order_item_id: nil,
                                      remarks: nil,
                                      quantity_returned: nil)
                     elsif @mode == :print_barcode
                       form_object_for_barcode_print
                     else
                       @repo.find_mr_sales_return_item(@options[:id])
                     end
    end

    def form_object_for_barcode_print
      rec = @repo.sales_return_item_sku_info(@options[:id])

      @form_object = OpenStruct.new(rec.merge(printer: @print_repo.default_printer_for_application(AppConst::PRINT_APP_MR_SKU_BARCODE)))
    end

    def allowed_options
      @repo.sales_returns_item_options(@options[:parent_id])
    end
  end
end
