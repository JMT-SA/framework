# frozen_string_literal: true

module PackMaterial
  module Config
    module PmProduct
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pm_product, :show, id: id)
          rules   = ui_rule.compile

          repo = PackMaterialApp::ConfigRepo.new
          set = repo.product_code_columns(ui_rule.form_object.material_resource_sub_type_id).map { |r| r[0].to_sym }

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :material_resource_sub_type_id
              form.add_field :product_number
              form.add_field :product_code

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
