# frozen_string_literal: true

module PackMaterial
  module Tripsheets
    module VehicleJob
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:vehicle_job, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New Tripsheet'
              form.action '/pack_material/tripsheets/vehicle_jobs'
              form.remote! if remote
              form.add_field :business_process_id
              form.add_field :vehicle_id
              form.add_field :departure_location_id
              # form.add_field :tripsheet_number
              form.add_field :planned_location_id
              form.add_field :virtual_location_id
              form.add_field :description
              # form.add_field :when_loaded
              # form.add_field :when_offloaded
            end
          end

          layout
        end
      end
    end
  end
end
