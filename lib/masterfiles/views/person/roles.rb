# frozen_string_literal: true

module Masterfiles
  module Parties
    module Person
      class Roles
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:person, :roles, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/parties/people/#{id}/roles"
              form.remote!
              form.add_field :name
              form.add_field :roles
            end
          end

          layout
        end
      end
    end
  end
end