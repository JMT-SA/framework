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
  end
end
