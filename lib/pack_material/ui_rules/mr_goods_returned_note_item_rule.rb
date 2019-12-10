# frozen_string_literal: true

module UiRules
  class MrGoodsReturnedNoteItemRule < Base
    def generate_rules
      @repo = PackMaterialApp::DispatchRepo.new
      make_form_object
      apply_form_values

      rules[:zero_options] = allowed_options.none? if @mode == :new
      common_values_for_fields @mode == :new ? new_fields : common_fields

      form_name 'mr_goods_returned_note_item'
    end

    def new_fields
      {
        delivery_item: { renderer: :select, options: allowed_options, caption: 'Delivery Item/Batch' }
      }
    end

    def common_fields
      {
        mr_goods_returned_note_id: { renderer: :hidden },
        mr_delivery_item_id: { renderer: :hidden },
        mr_delivery_item_batch_id: { renderer: :hidden },
        remarks: {},
        quantity_returned: {}
      }
    end

    def allowed_options
      PackMaterialApp::DispatchRepo.new.goods_returned_note_item_options(@options[:parent_id])
    end

    def make_form_object
      if @mode == :new
        make_new_form_object
        return
      end

      @form_object = @repo.find_mr_goods_returned_note_item(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mr_goods_returned_note_id: nil,
                                    mr_delivery_item_id: nil,
                                    mr_delivery_item_batch_id: nil,
                                    remarks: nil,
                                    quantity_returned: nil)
    end
  end
end
