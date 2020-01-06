# frozen_string_literal: true

module Masterfiles
  module TargetMarkets
    module Country
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:country, :new, form_values: form_values, region_id: parent_id)
          rules   = ui_rule.compile

          form_action = if parent_id.nil?
                          '/masterfiles/target_markets/destination_countries'
                        else
                          "/masterfiles/target_markets/destination_regions/#{parent_id}/destination_countries"
                        end

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action form_action
              form.remote! if remote
              form.add_field :destination_region_id
              form.add_field :country_name
              form.add_field :iso_country_code
            end
          end

          layout
        end
      end
    end
  end
end
