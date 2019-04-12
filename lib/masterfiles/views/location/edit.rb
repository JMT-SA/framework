# frozen_string_literal: true

module Masterfiles
  module Locations
    module Location
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:location, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/masterfiles/locations/locations/#{id}"
              form.remote!
              form.method :update
              form.add_field :location_type_id
              form.add_field :primary_storage_type_id
              form.add_field :primary_assignment_id
              form.add_field :location_storage_definition_id
              form.add_field :location_long_code
              form.add_field :location_description
              form.add_field :location_short_code
              form.add_field :print_code
              form.add_field :has_single_container
              form.add_field :virtual_location
              form.add_field :consumption_area
              form.add_field :can_be_moved
              form.add_field :can_store_stock
            end
          end

          layout
        end
      end
    end
  end
end
