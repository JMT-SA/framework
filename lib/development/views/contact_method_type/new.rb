# frozen_string_literal: true

module Development
  module Masterfiles
    module ContactMethodType
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:contact_method_type, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/development/masterfiles/contact_method_types'
              form.remote! if remote
              form.add_field :contact_method_type
            end
          end

          layout
        end
      end
    end
  end
end
