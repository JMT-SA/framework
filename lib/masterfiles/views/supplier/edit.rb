# frozen_string_literal: true

module Masterfiles
  module Parties
    module Supplier
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:supplier, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/parties/suppliers/#{id}"
              form.remote!
              form.method :update
              # form.add_field :party_role_id
              form.add_field :party_name
              form.add_field :erp_supplier_number
              form.add_field :supplier_type_ids
            end
          end

          layout
        end
      end
    end
  end
end
