# frozen_string_literal: true

module Masterfiles
  module Parties
    module Supplier
      class New
        def self.call(party_id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:supplier, :new, party_id: party_id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/masterfiles/parties/suppliers'
              form.remote! if remote
              form.add_field :party_name
              form.add_field :party_id
              form.add_field :supplier_type_id
              form.add_field :erp_supplier_number
            end
          end

          layout
        end
      end
    end
  end
end
