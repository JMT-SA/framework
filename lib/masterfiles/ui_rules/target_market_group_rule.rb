# frozen_string_literal: true

module UiRules
  class TargetMarketGroupRule < Base
    def generate_rules
      @repo = MasterfilesApp::TargetMarketRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'target_market_group'
    end

    def set_show_fields
      tm_group_type_id_label = @repo.find_tm_group_type(@form_object.target_market_group_type_id)&.target_market_group_type_code
      fields[:target_market_group_type_id] = { renderer: :label, with_value: tm_group_type_id_label }
      fields[:target_market_group_name] = { renderer: :label }
    end

    def common_fields
      {
        target_market_group_type_id: { renderer: :select, options: @repo.for_select_target_market_group_types },
        target_market_group_name: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_tm_group(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(target_market_group_type_id: nil,
                                    target_market_group_name: nil)
    end
  end
end
