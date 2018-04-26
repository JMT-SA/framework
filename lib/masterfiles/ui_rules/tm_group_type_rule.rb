# frozen_string_literal: true

module UiRules
  class TmGroupTypeRule < Base
    def generate_rules
      @repo = MasterfilesApp::TargetMarketRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'tm_group_type'
    end

    def set_show_fields
      fields[:target_market_group_type_code] = { renderer: :label }
    end

    def common_fields
      {
        target_market_group_type_code: { required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_tm_group_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(target_market_group_type_code: nil)
    end
  end
end
