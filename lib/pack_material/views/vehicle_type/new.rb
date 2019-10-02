# frozen_string_literal: true

module PackMaterial
  module Tripsheets
    module VehicleType
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:vehicle_type, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Vehicle Type'
              form.action '/pack_material/tripsheets/vehicle_types'
              form.remote! if remote
              form.add_field :type_code
            end
          end

          layout
        end
      end
    end
  end
end
