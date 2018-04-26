# frozen_string_literal: true

module Masterfiles
  module TargetMarkets
    module TargetMarket
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:target_market, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
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
