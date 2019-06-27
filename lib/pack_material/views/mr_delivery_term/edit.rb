# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDeliveryTerm
      class Edit
        def self.call(id, form_values: nil, form_errors: nil)
          ui_rule = UiRules::Compiler.new(:mr_delivery_term, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/replenish/mr_delivery_terms/#{id}"
              form.remote!
              form.method :update
              form.add_field :delivery_term_code
              form.add_field :is_consignment_stock
            end
          end

          layout
        end
      end
    end
  end
end
