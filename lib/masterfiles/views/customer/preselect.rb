# frozen_string_literal: true

module Masterfiles
  module Parties
    module Customer
      class Preselect
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:customer, :preselect, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/masterfiles/parties/customers/new'
              form.remote! if remote
              form.add_field :party_id
            end
          end

          layout
        end
      end
    end
  end
end
