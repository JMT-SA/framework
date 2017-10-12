# frozen_string_literal: true

module UiRules
  class CommodityGroup < Base
    def generate_rules
      @this_repo = CommodityGroupRepo.new
      make_form_object

      set_common_fields common_fields

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

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(code: nil,
                                    description: nil,
                                    active: true)
    end
  end
end
