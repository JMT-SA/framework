# frozen_string_literal: true

module PackMaterial
  module Config
    module PmProduct
      class Edit
        def self.call(id, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:pm_product, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/pack_material/config/pack_material_products/#{id}"
              form.remote!
              form.method :update
              form.add_field :material_resource_sub_type_id
              form.add_field :commodity_id
              form.add_field :variety_id
              form.add_field :product_number
              form.add_field :product_code
              form.add_field :unit
              form.add_field :style
              form.add_field :alternate
              form.add_field :shape
              form.add_field :reference_size
              form.add_field :reference_quantity
              form.add_field :length_mm
              form.add_field :width_mm
              form.add_field :height_mm
              form.add_field :diameter_mm
              form.add_field :thick_mm
              form.add_field :thick_mic
              form.add_field :brand_1
              form.add_field :brand_2
              form.add_field :colour
              form.add_field :material
              form.add_field :assembly
              form.add_field :reference_mass
              form.add_field :reference_number
              form.add_field :market
              form.add_field :marking
              form.add_field :model
              form.add_field :pm_class
              form.add_field :grade
              form.add_field :language
              form.add_field :other
              form.add_field :specification_notes
            end
          end

          # product_column_options = ProductTypeRepo.new.product_column_options(id)
          # product_column_options.keys.each do |key|
          #   form.add_text "<b>#{ key.to_s.capitalize.gsub('_', ' ') }</b>"
          #   product_column_options[key].keys.each do |sub|
          #     form.add_field :"#{sub}"
          #
          #   end
          # end
          #
          # Repo method:
          #   def product_column_options(product_id)
          #     options = {}
          #     product_type_id = DB[:products].where(id: product_id).select(:product_type_id).single_value
          #     product_column_ids = DB[:product_types_product_column_names].where(product_type_id: product_type_id).select_map(:product_column_name_id)
          #     product_columns = DB[:product_column_names].where(id: product_column_ids).select_map{|x| [x.group_name, x.column_name] }
          #     product_columns.each do |col|
          #       options[:"#{col[0]}"] = {} unless options[:"#{col[0]}"]
          #       options[:"#{col[0]}"][:"#{col[1]}"] = true
          #     end
          #     options
          #   end
          layout
        end
      end
    end
  end
end
