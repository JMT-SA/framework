# frozen_string_literal: true

module Masterfiles
  module Locations
    module LocationAssignment
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:location_assignment, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :assignment_code
            end
          end

          layout
        end
      end
    end
  end
end
