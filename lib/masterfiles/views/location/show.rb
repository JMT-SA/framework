# frozen_string_literal: true

module Masterfiles
  module Locations
    module Location
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:location, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
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
              form.add_field :storage_types
              form.add_field :assignments
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
