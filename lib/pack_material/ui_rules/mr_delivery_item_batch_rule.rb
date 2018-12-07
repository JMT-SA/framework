# frozen_string_literal: true

module UiRules
  class MrDeliveryItemBatchRule < Base
    def generate_rules
      @repo = PackMaterialApp::ReplenishRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_print_fields if @mode == :print_barcode

      form_name 'mr_delivery_item_batch'
    end

    private

    def set_show_fields
      fields[:internal_batch_number] = { renderer: :label }
      fields[:client_batch_number] = { renderer: :label }
      fields[:quantity_on_note] = { renderer: :label }
      fields[:quantity_received] = { renderer: :label }
    end

    def set_print_fields
      repo = LabelApp::PrinterRepo.new
      fields[:sku_number] = { renderer: :label }
      fields[:product_variant_code] = { renderer: :label }
      fields[:batch_number] = { renderer: :label }
      fields[:printer] = { renderer: :select,
                           options: repo.select_printers_for_application(AppConst::PRINT_APP_MR_SKU_BARCODE),
                           required: true }
      fields[:no_of_prints] = { renderer: :integer, required: true }
    end

    def common_fields
      {
        mr_delivery_item_id: { renderer: :hidden },
        mr_internal_batch_number_id: { renderer: :select, options: @repo.for_select_mr_internal_batch_numbers, caption: 'Internal Batch Number', prompt: true },
        client_batch_number: {},
        quantity_on_note: { renderer: :numeric, required: true },
        quantity_received: { renderer: :numeric, required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new
      form_object_for_barcode_print && return if @mode == :print_barcode

      @form_object = @repo.find_mr_delivery_item_batch(@options[:id])
    end

    def form_object_for_barcode_print
      rec = @repo.sku_for_barcode(@options[:id])
      @form_object = OpenStruct.new(rec.merge(printer: nil))
    end

    def make_new_form_object
      item = mr_delivery_item
      @form_object = OpenStruct.new(mr_delivery_item_id: item.id,
                                    mr_internal_batch_number_id: nil,
                                    client_batch_number: nil,
                                    quantity_on_note: item.quantity_on_note,
                                    quantity_received: item.quantity_received)
    end

    def mr_delivery_item
      @repo.find_mr_delivery_item(@options[:parent_id])
    end
  end
end
