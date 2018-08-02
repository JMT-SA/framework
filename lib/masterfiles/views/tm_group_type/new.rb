# frozen_string_literal: true

module Masterfiles
  module TargetMarkets
    module TmGroupType
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:tm_group_type, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/masterfiles/target_markets/target_market_group_types'
              form.remote! if remote
              form.add_field :target_market_group_type_code
            end
          end

          layout
        end
      end
    end
  end
end
