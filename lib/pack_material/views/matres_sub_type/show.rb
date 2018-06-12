# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresSubType
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:matres_sub_type, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :material_resource_type_id
              form.add_field :sub_type_name
              form.add_field :short_code
            end
          end

          layout
        end
      end
    end
  end
end
