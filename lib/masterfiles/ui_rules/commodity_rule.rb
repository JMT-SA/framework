# frozen_string_literal: true

module UiRules
  class CommodityRule < Base
    def generate_rules
      @repo = MasterfilesApp::CommodityRepo.new
      make_form_object

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'commodity'
    end

    def set_show_fields
      fields[:commodity_group_id] = { renderer: :label,
                                      with_value: @repo.find_commodity_group(@form_object.commodity_group_id)&.code }
      fields[:code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:hs_code] = { renderer: :label }
      fields[:active] = { renderer: :label }
    end

    def common_fields
      {
        commodity_group_id: { renderer: :select, options: @repo.for_select_commodity_groups, disabled_options: @repo.for_select_inactive_commodity_groups },
        code: {},
        description: {},
        hs_code: {},
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_commodity(@options[:id])
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
