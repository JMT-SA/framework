# frozen_string_literal: true

module PackMaterialApp
  class PmProductRepo < BaseRepo
    build_for_select :pack_material_products,
                     label: :product_code,
                     alias: 'pm_products',
                     value: :id,
                     order_by: :product_code
    build_inactive_select :pack_material_products,
                          label: :product_code,
                          alias: 'pm_products',
                          value: :id,
                          order_by: :product_code

    crud_calls_for :pack_material_products, name: :pm_product, wrapper: PmProduct
    crud_calls_for :pack_material_product_variants, name: :pm_product_variant, wrapper: PmProductVariant

    def summary
      query = <<~SQL
        SELECT 'Number of products' AS item, COUNT(*) AS quantity FROM pack_material_products
        UNION ALL
        SELECT 'Number of variants' AS item, COUNT(*) AS quantity FROM pack_material_product_variants
      SQL
      DB[query].all
    end

    def delete_pm_product(id)
      if (pm_variant_ids = pm_variant_ids(id).empty?)
        delete(:pack_material_products, id)
        success_response('ok')
      else
        failed_response('There are variants linked to this product', associated_variant_ids: pm_variant_ids)
      end
    end

    def update_pm_product(id, attrs)
      if (pm_variant_ids = pm_variant_ids(id).empty?)
        update(:pack_material_products, id, attrs)
        success_response('ok')
      else
        failed_response('There are variants linked to this product', associated_variant_ids: pm_variant_ids)
      end
    end

    def pm_variant_ids(id)
      DB[:pack_material_product_variants].where(pack_material_product_id: id).all.map { |r| r[:id] }
    end

    def create_pm_product_variant(attrs)
      sub_type_id = DB[:pack_material_products].where(id: attrs[:pack_material_product_id]).first[:material_resource_sub_type_id]
      return validation_failed_response(OpenStruct.new(messages: { base: ['This product variant already exists'] })) if where_hash(:pack_material_product_variants, variant_defining_values(sub_type_id, attrs))

      variant_id = create(:pack_material_product_variants, attrs)
      create_matres_product_variant(sub_type_id, variant_id)
      success_response('ok', variant_id)
    end

    # Select the variant-defining columns with their values from a set of attributes.
    # There should only ever be one variant with this set of values for a product.
    # For this reason, the result includes the +pack_material_product_id+.
    #
    # @param sub_type_id [integer] - the MaterialResourceSubType.id
    # @param attrs [hash, dry-type] - the attributes and values to filter down to a variant-defining set.
    # @return [hash] just the attribute values that have to be unique for a product.
    def variant_defining_values(sub_type_id, attrs)
      var_code_cols = ConfigRepo.new.product_variant_code_columns(sub_type_id).map { |r| r.first.to_sym }
      var_code_cols.push(:pack_material_product_id)
      attrs.to_h.select { |a| var_code_cols.include?(a) }
    end

    def create_matres_product_variant(sub_type_id, variant_id)
      variant = where_hash(:pack_material_product_variants, id: variant_id)
      create(:material_resource_product_variants, sub_type_id: sub_type_id,
                                                  product_variant_id: variant_id,
                                                  product_variant_table_name: 'pack_material_product_variants',
                                                  product_variant_number: variant[:product_variant_number],
                                                  product_variant_code: variant[:product_variant_code])
    end

    def delete_pm_product_variant(id)
      # TODO: this is temporary - more advanced rules will apply here
      variant = find_hash(:pack_material_product_variants, id)
      # You should not be able to delete a variant if its material resource variant has matres items
      # BUT - what about purchase orders, matres receipts, deliveries (see dia)
      matres_variant_id = DB[:material_resource_product_variants].where(
        product_variant_id: variant[:id],
        product_variant_table_name: 'pack_material_product_variants'
      ).first[:id]
      # items = DB[:material_resource_skus].where(material_resource_product_variant_id: matres_variant_id).all
      # unless items.any?
      delete(:material_resource_product_variants, matres_variant_id)
      delete(:pack_material_product_variants, id)
      # end
    end
  end
end
