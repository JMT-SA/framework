# frozen_string_literal: true

module Masterfiles
  module Locations
    module LocationStorageDefinition
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:location_storage_definition, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Location Storage Definition'
              form.action '/masterfiles/locations/location_storage_definitions'
              form.remote! if remote
              form.add_field :storage_definition_code
              form.add_field :storage_definition_format
              form.add_field :storage_definition_description
            end
          end

          layout
        end
      end
    end
  end
end
