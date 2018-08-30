# frozen_string_literal: true

module Masterfiles
  module Parties
    module Customer
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:customer, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :party_name
              form.add_field :party_role_id
              form.add_field :customer_type_id
              form.add_field :erp_customer_number
            end
          end

          layout
        end
      end
    end
  end
end
