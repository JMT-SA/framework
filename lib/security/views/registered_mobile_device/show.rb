# frozen_string_literal: true

module Security
  module Rmd
    module RegisteredMobileDevice
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:registered_mobile_device, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
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
