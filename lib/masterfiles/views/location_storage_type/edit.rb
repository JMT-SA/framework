# frozen_string_literal: true

module Masterfiles
  module Locations
    module LocationStorageType
      class Edit
        def self.call(id, form_values: nil, form_errors: nil)
          ui_rule = UiRules::Compiler.new(:location_storage_type, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/locations/location_storage_types/#{id}"
              form.remote!
              form.method :update
              form.add_field :storage_type_code
              form.add_field :location_short_code_prefix
            end
          end

          layout
        end
      end
    end
  end
end
