# frozen_string_literal: true

module PackMaterial
  module Replenish
    module MrDeliveryTerm
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:mr_delivery_term, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
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
