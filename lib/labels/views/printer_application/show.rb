# frozen_string_literal: true

module Labels
  module Printers
    module PrinterApplication
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:printer_application, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :printer_id
              form.add_field :application
              form.add_field :active
              form.add_field :default_printer
            end
          end

          layout
        end
      end
    end
  end
end
