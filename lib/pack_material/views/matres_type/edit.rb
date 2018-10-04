# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresType
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:matres_type, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/material_resource_types/#{id}"
              form.remote!
              form.method :update
              form.add_field :material_resource_domain_name
              form.add_field :material_resource_domain_id
              form.add_field :type_name
              form.add_field :short_code
              form.add_field :description
            end
          end

          layout
        end
      end
    end
  end
end
