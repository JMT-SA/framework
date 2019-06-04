# frozen_string_literal: true

module Labels
  module Printers
    module PrinterApplication
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:printer_application, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/labels/printers/printer_applications'
              form.remote! if remote
              form.add_field :printer_id
              form.add_field :application
              form.add_field :default_printer
            end
          end

          layout
        end
      end
    end
  end
end
