# frozen_string_literal: true

module Masterfiles
  module Fruit
    module MarketingVariety
      class Edit
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:marketing_variety, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/fruit/marketing_varieties/#{id}"
              form.remote!
              form.method :update
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
