# frozen_string_literal: true

module Masterfiles
  module Locations
    module LocationType
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:location_type, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/masterfiles/locations/location_types'
              form.remote! if remote
              form.add_field :location_type_code
              form.add_field :short_code
            end
          end

          layout
        end
      end
    end
  end
end
