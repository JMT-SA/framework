# frozen_string_literal: true

module UiRules
  class MarketingVarietyRule < Base
    def generate_rules
      @repo = CultivarRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'marketing_variety'
    end

    def set_show_fields
      fields[:marketing_variety_code] = { renderer: :label }
      fields[:description] = { renderer: :label }
    end

    def common_fields
      {
        marketing_variety_code: {},
        description: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_marketing_variety(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(marketing_variety_code: nil,
                                    description: nil)
    end
  end
end
