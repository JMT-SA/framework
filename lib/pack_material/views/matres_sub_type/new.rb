# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresSubType
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:matres_sub_type, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/pack_material/config/material_resource_sub_types'
              form.remote! if remote
              form.add_field :material_resource_type_id
              form.add_field :sub_type_name
            end
          end

          layout
        end
      end
    end
  end
end
