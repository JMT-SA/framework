# frozen_string_literal: true

module Masterfiles
  module Parties
    module Organization
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:organization, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/parties/organizations/#{id}"
              form.remote!
              form.method :update
              # form.add_field :party_id
              form.add_field :parent_id
              form.add_field :short_description
              form.add_field :medium_description
              form.add_field :long_description
              form.add_field :vat_number
              # form.add_field :variants
              # form.add_field :active
              form.add_field :role_ids
            end
          end

          layout
        end
      end
    end
  end
end
