# frozen_string_literal: true

module PackMaterial
  module Tripsheets
    module VehicleJobUnit
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:vehicle_job_unit, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Tripsheet Item'
              form.view_only!
              form.add_field :mr_sku_location_from_id
              form.add_field :vehicle_job_id
              form.add_field :mr_sku_id
              form.add_field :sku_number
              form.add_field :location_id
              form.add_field :quantity_to_move
              form.add_field :quantity_loaded
              form.add_field :quantity_offloaded
              form.add_field :when_loaded
              form.add_field :when_offloading
              form.add_field :when_loading
              form.add_field :when_offloaded
            end
          end

          layout
        end
      end
    end
  end
end
