# frozen_string_literal: true

module PackMaterial
  module Tripsheets
    module VehicleJobUnit
      class Edit
        def self.call(id, form_values: nil, form_errors: nil)
          ui_rule = UiRules::Compiler.new(:vehicle_job_unit, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'Edit Vehicle Job Unit'
              form.action "/pack_material/tripsheets/vehicle_job_units/#{id}"
              form.remote!
              form.method :update
              form.add_field :mr_sku_location_from_id
              form.add_field :mr_inventory_transaction_item_id
              form.add_field :vehicle_job_id
              form.add_field :quantity_to_move
              form.add_field :when_loaded
              form.add_field :when_offloaded
              form.add_field :when_offloading
              form.add_field :quantity_moved
              form.add_field :when_loading
            end
          end

          layout
        end
      end
    end
  end
end
