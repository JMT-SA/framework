# frozen_string_literal: true

module UiRules
  class Commodity < Base
    def generate_rules
      @this_repo = CommodityRepo.new
      make_form_object

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'commodity'
    end

    def set_show_fields
      commodity_group_id_label = CommodityGroupRepo.new.find(@form_object.commodity_group_id)&.code
      fields[:commodity_group_id] = { renderer: :label, with_value: commodity_group_id_label }
      fields[:code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:hs_code] = { renderer: :label }
      fields[:active] = { renderer: :label }
    end

    def common_fields
      {
        commodity_group_id: { renderer: :select, options: CommodityGroupRepo.new.for_select },
        code: {},
        description: {},
        hs_code: {},
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(commodity_group_id: nil,
                                    code: nil,
                                    description: nil,
                                    hs_code: nil,
                                    active: true)
    end
  end
end
