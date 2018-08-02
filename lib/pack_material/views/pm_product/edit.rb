# frozen_string_literal: true

module PackMaterial
  module Config
    module PmProduct
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pm_product, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          repo = PackMaterialApp::ConfigRepo.new
          set = repo.product_code_columns(ui_rule.form_object.material_resource_sub_type_id).map { |r| r[0].to_sym }

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/pack_material_products/#{id}"
              form.remote!
              form.method :update
              form.add_field :material_resource_sub_type_name
              form.add_field :material_resource_sub_type_id

              set.each do |item|
                form.add_field item
              end

              form.add_field :specification_notes
            end
          end
          layout
        end
      end
    end
  end
end
