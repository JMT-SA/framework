# frozen_string_literal: true

module UiRules
  class CommodityGroupRule < Base
    def generate_rules
      @repo = CommodityRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'commodity_group'
    end

    def set_show_fields
      fields[:code] = { renderer: :label }
      fields[:description] = { renderer: :label }
      fields[:active] = { renderer: :label }
    end

    def common_fields
      {
        code: {},
        description: {},
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_commodity_group(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(code: nil,
                                    description: nil,
                                    active: true)
    end
  end
end