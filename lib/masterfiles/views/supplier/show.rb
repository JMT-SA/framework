# frozen_string_literal: true

module Masterfiles
  module Parties
    module Supplier
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:supplier, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :party_name
              form.add_field :party_role_id
              form.add_field :erp_supplier_number
              form.add_field :supplier_types
            end
          end

          layout
        end
      end
    end
  end
end
