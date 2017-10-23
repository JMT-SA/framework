# frozen_string_literal: true

module Development
  module Masterfiles
    module AddressType
      class New
        def self.call(form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:address_type, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/development/masterfiles/address_types'
              form.remote!
              form.add_field :address_type
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
