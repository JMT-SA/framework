# frozen_string_literal: true

module Masterfiles
  module Locations
    module LocationType
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:location_type, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :location_type_code
              form.add_field :short_code
              form.add_field :can_be_moved
            end
          end

          layout
        end
      end
    end
  end
end
