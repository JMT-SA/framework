# frozen_string_literal: true

module PackMaterial
  module Tripsheets
    module VehicleType
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:vehicle_type, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Vehicle Type'
              form.view_only!
              form.add_field :type_code
            end
          end

          layout
        end
      end
    end
  end
end
