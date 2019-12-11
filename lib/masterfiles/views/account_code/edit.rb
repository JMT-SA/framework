# frozen_string_literal: true

module Masterfiles
  module PackMaterial
    module AccountCode
      class Edit
        def self.call(id, form_values: nil, form_errors: nil)
          ui_rule = UiRules::Compiler.new(:account_code, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'Edit Account Code'
              form.action "/masterfiles/pack_material/account_codes/#{id}"
              form.remote!
              form.method :update
              form.add_field :account_code
              form.add_field :description
            end
          end

          layout
        end
      end
    end
  end
end
