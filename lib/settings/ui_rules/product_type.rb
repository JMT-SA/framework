# frozen_string_literal: true

module UiRules
  class ProductTypeRule < Base
    def generate_rules
      @this_repo = ProductTypeRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'product_type'

      add_behaviours
    end

    def set_show_fields
      product_type_name_id_label = ProductTypeRepo.new.find_packing_material_product_type(@form_object.packing_material_product_type_id)&.packing_material_type_name
      product_sub_type_name_id_label = ProductTypeRepo.new.find_packing_material_product_sub_type(@form_object.packing_material_product_sub_type_id)&.packing_material_sub_type_name
      fields[:packing_material_product_type_id] = { renderer: :label, with_value: product_type_name_id_label, caption: 'Product Type Name' }
      fields[:packing_material_product_sub_type_id] = { renderer: :label, with_value: product_sub_type_name_id_label, caption: 'Product Sub Type Name' }
    end

    def common_fields
      {
        packing_material_product_type_id: { renderer: :select, options: ProductTypeRepo.new.for_select_packing_material_product_types, caption: 'Product Type Name' },
        packing_material_product_sub_type_id: { renderer: :select, options: ProductTypeRepo.new.for_select_packing_material_product_sub_types, caption: 'Product Sub Type Name' }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find_product_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(packing_material_product_type_id: nil,
                                    packing_material_product_sub_type_id: nil)
    end

    def add_behaviours
      behaviours do |behaviour|
        behaviour.dropdown_change :packing_material_product_type_id, notify: [{ url: '/settings/products/product_types/select_change_for_product_sub_type_name' }]
      end
    end
  end
end
