# frozen_string_literal: true

module Masterfiles
  module Locations
    module LocationStorageType
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:location_storage_type, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :storage_type_code
              form.add_field :location_short_code_prefix
            end
          end

          layout
        end
      end
    end
  end
end
