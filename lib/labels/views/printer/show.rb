# frozen_string_literal: true

module Labels
  module Printers
    module Printer
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:printer, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :printer_code
              form.add_field :printer_name
              form.add_field :printer_type
              form.add_field :pixels_per_mm
              form.add_field :printer_language
              form.add_field :server_ip
              form.add_field :printer_use
            end
          end

          layout
        end
      end
    end
  end
end
