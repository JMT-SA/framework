# frozen_string_literal: true

module UiRules
  class MrDeliveryTermRule < Base
    def generate_rules
      @repo = PackMaterialApp::ReplenishRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'mr_delivery_term'
    end

    def set_show_fields
      fields[:delivery_term_code] = { renderer: :label }
      fields[:is_consignment_stock] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        delivery_term_code: {},
        is_consignment_stock: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_delivery_term(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(delivery_term_code: nil,
                                    is_consignment_stock: nil)
    end
  end
end
