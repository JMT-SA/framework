# frozen_string_literal: true

module Masterfiles
  module Locations
    module LocationStorageDefinition
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:location_storage_definition, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'Location Storage Definition'
              form.view_only!
              form.add_field :storage_definition_code
              form.add_field :storage_definition_format
              form.add_field :storage_definition_description
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
