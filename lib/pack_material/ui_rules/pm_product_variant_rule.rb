# frozen_string_literal: true

module UiRules
  class PmProductVariantRule < Base
    def generate_rules
      @repo = PackMaterialApp::PmProductRepo.new
      @config_repo = PackMaterialApp::ConfigRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'pm_product_variant'
    end

    def set_show_fields
      pm_product_id_label = @repo.find_pm_product(product_id)&.product_code
      fields[:pack_material_product] = { renderer: :label, with_value: pm_product_id_label, caption: 'Product' }
      fields[:pack_material_product_id] = { renderer: :hidden, value: product_id }
      fields[:product_variant_number] = { renderer: :label }
      fields[:unit] = { renderer: :label }
      fields[:style] = { renderer: :label }
      fields[:alternate] = { renderer: :label }
      fields[:shape] = { renderer: :label }
      fields[:reference_size] = { renderer: :label }
      fields[:reference_quantity] = { renderer: :label }
      fields[:length_mm] = { renderer: :label }
      fields[:width_mm] = { renderer: :label }
      fields[:height_mm] = { renderer: :label }
      fields[:diameter_mm] = { renderer: :label }
      fields[:thick_mm] = { renderer: :label }
      fields[:thick_mic] = { renderer: :label }
      fields[:brand_1] = { renderer: :label }
      fields[:brand_2] = { renderer: :label }
      fields[:colour] = { renderer: :label }
      fields[:material] = { renderer: :label }
      fields[:assembly] = { renderer: :label }
      fields[:reference_mass] = { renderer: :label }
      fields[:reference_number] = { renderer: :label }
      fields[:market] = { renderer: :label }
      fields[:marking] = { renderer: :label }
      fields[:model] = { renderer: :label }
      fields[:pm_class] = { renderer: :label }
      fields[:grade] = { renderer: :label }
      fields[:language] = { renderer: :label }
      fields[:other] = { renderer: :label }
    end

    def common_fields
      pm_product_id_label = @repo.find_pm_product(product_id)&.product_code
      x = {
        pack_material_product: { renderer: :label, with_value: pm_product_id_label, caption: 'Product', readonly: true },
        pack_material_product_id: { renderer: :hidden, with_value: product_id },
        product_variant_number: {}
      }

      product_column_set.each do |col_name, required|
        if col_name == :reference_dimension
          ref_dim = {
            # Separate setup for reference Dimension?
            length_mm: { renderer: :numeric }, # reference dimension -> H(100)xW(100)xL(100) OR H(100)xD(30)
            width_mm: { renderer: :numeric },
            height_mm: { renderer: :numeric },
            diameter_mm: { renderer: :numeric },
            thick_mm: { renderer: :numeric }, # Tmm(15)
            thick_mic: { renderer: :numeric }, # Tmic(165)
          }
          x.merge(ref_dim)
        else
          list = master_list_items(col_name)
          x[col_name] = list.any? ? { renderer: :select, options: list, caption: col_name.to_s.gsub('pm_', '').gsub('_', ' ').capitalize, required: required } : { required: required }
        end
      end
      x
    end

    def product_id
      @form_object.pack_material_product_id || @options[:parent_id]
    end

    def product_column_set
      product = @repo.find_pm_product(product_id)
      applicable_columns = @config_repo.product_variant_columns(product.material_resource_sub_type_id).map { |r| r.push(true) }
      applicable_columns_optional = @config_repo.product_variant_columns_optional(product.material_resource_sub_type_id).map { |r| r.push(false) }
      combined_set = applicable_columns + applicable_columns_optional
      combined_set.map { |r| [r[0].to_sym, r[2]] }
    end

    def master_list_items(product_column)
      product = @repo.find_pm_product(product_id)
      @config_repo.for_select_sub_type_master_list_items(product.material_resource_sub_type_id, product_column)
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_pm_product_variant(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(pack_material_product_id: nil,
                                    product_variant_number: nil,
                                    unit: nil,
                                    style: nil,
                                    alternate: nil,
                                    shape: nil,
                                    reference_size: nil,
                                    reference_quantity: nil,
                                    length_mm: nil,
                                    width_mm: nil,
                                    height_mm: nil,
                                    diameter_mm: nil,
                                    thick_mm: nil,
                                    thick_mic: nil,
                                    brand_1: nil,
                                    brand_2: nil,
                                    colour: nil,
                                    material: nil,
                                    assembly: nil,
                                    reference_mass: nil,
                                    reference_number: nil,
                                    market: nil,
                                    marking: nil,
                                    model: nil,
                                    pm_class: nil,
                                    grade: nil,
                                    language: nil,
                                    other: nil)
    end
  end
end
