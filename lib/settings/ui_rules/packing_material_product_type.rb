# frozen_string_literal: true

module UiRules
  class PackingMaterialProductTypeRule < Base
    def generate_rules
      @this_repo = ProductTypeRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'packing_material_product_type'
    end

    def set_show_fields
      fields[:packing_material_type_name] = { renderer: :label }
    end

    def common_fields
      {
        packing_material_type_name: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find_packing_material_product_type(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(packing_material_type_name: nil)
    end
  end
end
