# frozen_string_literal: true

module Masterfiles
  module Fruit
    module TargetMarket
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:target_market, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/target_markets/target_markets/#{id}"
              form.remote!
              form.method :update
              form.add_field :target_market_name
              form.add_field :tm_group_ids
              form.add_field :country_ids
            end
          end

          layout
        end
      end
    end
  end
end
