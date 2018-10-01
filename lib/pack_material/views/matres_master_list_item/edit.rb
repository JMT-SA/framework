# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresMasterListItem
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:matres_master_list_item, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          repo = PackMaterialApp::ConfigRepo.new
          item = repo.find_matres_master_list_item(id)
          list = repo.find_matres_master_list(item.material_resource_master_list_id)
          sub_type_id = list.material_resource_sub_type_id

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/material_resource_sub_types/#{sub_type_id}/material_resource_master_list_items/#{id}"
              form.remote!
              form.method :update
              # form.add_field :material_resource_master_list_id
              # form.add_field :short_code
              form.add_field :long_name
              form.add_field :description
            end
          end

          layout
        end
      end
    end
  end
end
