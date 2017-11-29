# frozen_string_literal: true

module UiRules
  class TargetMarketRule < Base
    def generate_rules
      @this_repo = TargetMarketRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'target_market'
    end

    def set_show_fields
      fields[:target_market_name] = { renderer: :label }
    end

    def common_fields
      {
        target_market_name: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(:target_markets, TargetMarket, @options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(target_market_name: nil)
    end
  end
end
