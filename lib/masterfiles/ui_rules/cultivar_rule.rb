# frozen_string_literal: true

module UiRules
  class CultivarRule < Base
    def generate_rules
      @repo = CultivarRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'cultivar'
    end

    def set_show_fields
      commodity_id_label = CommodityRepo.new.find_commodity(@form_object.commodity_id)&.code
      cultivar_group_id_label = @repo.find_cultivar_group(@form_object.cultivar_group_id)&.cultivar_group_code
      fields[:commodity_id] = { renderer: :label, with_value: commodity_id_label }
      fields[:cultivar_group_id] = { renderer: :label, with_value: cultivar_group_id_label }
      fields[:cultivar_name] = { renderer: :label }
      fields[:description] = { renderer: :label }
    end

    def common_fields
      {
        commodity_id: { renderer: :select, options: CommodityRepo.new.commodities_for_select},
        cultivar_group_id: { renderer: :select, options: @repo.cultivar_groups_for_select },
        cultivar_name: {},
        description: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_cultivar(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(commodity_id: nil,
                                    cultivar_group_id: nil,
                                    cultivar_name: nil,
                                    description: nil)
    end
  end
end
