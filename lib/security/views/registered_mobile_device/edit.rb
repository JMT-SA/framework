# frozen_string_literal: true

module Security
  module Rmd
    module RegisteredMobileDevice
      class Edit
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:registered_mobile_device, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.add_help_link path: %i[rmd rmd_properties], help_type: 'system', for_dialog: true
            page.form do |form|
              form.action "/security/rmd/registered_mobile_devices/#{id}"
              form.remote!
              form.method :update
              form.add_field :ip_address
              form.add_field :start_page_program_function_id
              form.add_field :active
              form.add_field :scan_with_camera
              form.add_field :hybrid_device
            end
          end

          layout
        end
      end
    end
  end
end
