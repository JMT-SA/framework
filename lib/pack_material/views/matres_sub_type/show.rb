# frozen_string_literal: true

module PackMaterial
  module Config
    module MatresSubType
      class Show
        def self.call(id) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:matres_sub_type, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :material_resource_type_id
              form.add_field :sub_type_name
              form.add_field :short_code
              form.add_field :internal_seq
              form.add_field :product_code_separator
              form.add_field :has_suppliers
              form.add_field :has_marketers
              form.add_field :has_retailers
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
