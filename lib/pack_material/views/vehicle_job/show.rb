# frozen_string_literal: true

module PackMaterial
  module Tripsheets
    module VehicleJob
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:vehicle_job, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Vehicle Job'
              form.view_only!
              form.add_field :business_process_id
              form.add_field :vehicle_id
              form.add_field :departure_location_id
              form.add_field :tripsheet_number
              form.add_field :planned_location_id
              form.add_field :virtual_location_id
              form.add_field :when_loaded
              form.add_field :when_offloaded
            end
          end

          layout
        end
      end
    end
  end
end
