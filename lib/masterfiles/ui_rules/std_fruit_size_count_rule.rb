# frozen_string_literal: true

module UiRules
  class StdFruitSizeCountRule < Base
    def generate_rules
      @this_repo = StdFruitSizeCountRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'std_fruit_size_count'
    end

    def set_show_fields
      commodity_id_label = CommodityRepo.new.find_commodity(@form_object.commodity_id)&.code
      fields[:commodity_id] = { renderer: :label, with_value: commodity_id_label }
      fields[:size_count_description] = { renderer: :label }
      fields[:marketing_size_range_mm] = { renderer: :label }
      fields[:marketing_weight_range] = { renderer: :label }
      fields[:size_count_interval_group] = { renderer: :label }
      fields[:size_count_value] = { renderer: :label }
      fields[:minimum_size_mm] = { renderer: :label }
      fields[:maximum_size_mm] = { renderer: :label }
      fields[:average_size_mm] = { renderer: :label }
      fields[:minimum_weight_gm] = { renderer: :label }
      fields[:maximum_weight_gm] = { renderer: :label }
      fields[:average_weight_gm] = { renderer: :label }
    end

    def common_fields
      {
        commodity_id: { renderer: :select, options: CommodityRepo.new.commodities_for_select },
        size_count_description: {},
        marketing_size_range_mm: {},
        marketing_weight_range: {},
        size_count_interval_group: {},
        size_count_value: {},
        minimum_size_mm: { caption: 'min' },
        maximum_size_mm: { caption: 'max' },
        average_size_mm: { caption: 'avg' },
        minimum_weight_gm: {},
        maximum_weight_gm: {},
        average_weight_gm: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(commodity_id: nil,
                                    size_count_description: nil,
                                    marketing_size_range_mm: nil,
                                    marketing_weight_range: nil,
                                    size_count_interval_group: nil,
                                    size_count_value: nil,
                                    minimum_size_mm: nil,
                                    maximum_size_mm: nil,
                                    average_size_mm: nil,
                                    minimum_weight_gm: nil,
                                    maximum_weight_gm: nil,
                                    average_weight_gm: nil)
    end
  end
end
