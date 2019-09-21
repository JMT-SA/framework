# frozen_string_literal: true

module PackMaterial
  module Tripsheets
    module VehicleJobUnit
      class New
        def self.call(parent_id, form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:vehicle_job_unit, :new, form_values: form_values, parent_id: parent_id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Vehicle Job Unit'
              form.action "/pack_material/tripsheets/vehicle_jobs/#{parent_id}/vehicle_job_units"
              form.remote! if remote
              form.add_field :sku_location_lookup
              form.add_field :mr_sku_location_from_id
              form.add_field :vehicle_job_id
              form.add_field :mr_sku_id
              form.add_field :sku_number
              form.add_field :location_id
              form.add_field :location_code
              form.add_field :quantity_to_move
            end
          end

          layout
        end
      end
    end
  end
end
