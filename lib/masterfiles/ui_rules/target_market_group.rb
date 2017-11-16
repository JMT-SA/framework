# frozen_string_literal: true

module UiRules
  class TargetMarketGroup < Base
    def generate_rules
      @this_repo = TargetMarketGroupRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'target_market_group'
    end

    def set_show_fields
      target_market_group_type_id_label = TargetMarketGroupTypeRepo.new.find(@form_object.target_market_group_type_id)&.target_market_group_type_code
      fields[:target_market_group_type_id] = { renderer: :label, with_value: target_market_group_type_id_label }
      fields[:target_market_group_name] = { renderer: :label }
    end

    def common_fields
      {
        target_market_group_type_id: { renderer: :select, options: TargetMarketGroupTypeRepo.new.for_select },
        target_market_group_name: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(target_market_group_type_id: nil,
                                    target_market_group_name: nil)
    end
  end
end
