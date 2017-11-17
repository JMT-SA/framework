# frozen_string_literal: true

module Masterfiles
  module Fruit
    module MarketingVariety
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:marketing_variety, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :marketing_variety_code
              form.add_field :description
            end
          end

          layout
        end
      end
    end
  end
end
