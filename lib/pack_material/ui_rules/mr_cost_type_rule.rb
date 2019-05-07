# frozen_string_literal: true

module UiRules
  class MrCostTypeRule < Base
    def generate_rules
      @repo = PackMaterialApp::ReplenishRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      form_name 'mr_cost_type'
    end

    def set_show_fields
      fields[:cost_type_code] = { renderer: :label }
    end

    def common_fields
      {
        cost_type_code: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_mr_cost_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(cost_type_code: nil)
    end
  end
end
