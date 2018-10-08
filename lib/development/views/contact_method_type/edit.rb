# frozen_string_literal: true

module Development
  module Masterfiles
    module ContactMethodType
      class Edit
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:contact_method_type, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/development/masterfiles/contact_method_types/#{id}"
              form.remote!
              form.method :update
              form.add_field :contact_method_type
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
