# frozen_string_literal: true

module Masterfiles
  module Parties
    module Person
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:person, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/parties/people/#{id}"
              form.remote!
              form.method :update
              form.add_field :title
              form.add_field :first_name
              form.add_field :surname
              form.add_field :vat_number
              form.add_field :role_ids
            end
          end

          layout
        end
      end
    end
  end
end
