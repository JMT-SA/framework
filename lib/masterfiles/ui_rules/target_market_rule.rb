# frozen_string_literal: true

module UiRules
  class TargetMarketRule < Base
    def generate_rules
      @repo = MasterfilesApp::TargetMarketRepo.new
      @destination_repo = MasterfilesApp::DestinationRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'target_market'
    end

    def set_show_fields
      fields[:target_market_name] = { renderer: :label }
      fields[:tm_group_ids] = { renderer: :list, caption: 'Groups', items: @repo.target_market_group_names_for(@options[:id]) }
      fields[:country_ids] = { renderer: :list, caption: 'Countries', items: @repo.destination_country_names_for(@options[:id]) }
    end

    def common_fields
      {
        target_market_name: { required: true, caption: 'Target Market Name' },
        tm_group_ids: { renderer: :multi, options: @repo.for_select_tm_groups, selected: @form_object.tm_group_ids, caption: 'Groups', required: true },
        country_ids: { renderer: :multi, options: @destination_repo.for_select_destination_countries, selected: @form_object.country_ids, caption: 'Countries', required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_target_market(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(target_market_name: nil,
                                    country_ids: [],
                                    tm_group_ids: [])
    end
  end
end
