# frozen_string_literal: true

module Masterfiles
  module Fruit
    module CommodityGroup
      class Edit
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:commodity_group, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/fruit/commodity_groups/#{id}"
              form.remote!
              form.method :update
              form.add_field :code
              form.add_field :description
            end
          end

          layout
        end
      end
    end
  end
end
