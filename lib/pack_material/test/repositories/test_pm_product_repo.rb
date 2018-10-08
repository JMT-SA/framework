# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestPmProductRepo < MiniTestWithHooks
    include PmProductFactory
    include ConfigFactory

    def test_for_selects
      assert_respond_to repo, :for_select_pm_products
      assert_respond_to repo, :for_select_inactive_pm_products
    end

    def test_crud_calls
      assert_respond_to repo, :find_pm_product
      assert_respond_to repo, :create_pm_product
      assert_respond_to repo, :update_pm_product
      assert_respond_to repo, :delete_pm_product

      assert_respond_to repo, :find_pm_product_variant
      assert_respond_to repo, :create_pm_product_variant
      assert_respond_to repo, :update_pm_product_variant
      assert_respond_to repo, :delete_pm_product_variant
    end

    # def summary
    #   query = <<~SQL
    #     SELECT 'Number of products' AS item, COUNT(*) AS quantity FROM pack_material_products
    #     UNION ALL
    #     SELECT 'Number of variants' AS item, COUNT(*) AS quantity FROM pack_material_product_variants
    #   SQL
    #   DB[query].all
    # end
    #
    # def delete_pm_product(id)
    #   if (pm_variant_ids = pm_variant_ids(id).empty?)
    #     delete(:pack_material_products, id)
    #     success_response('ok')
    #   else
    #     failed_response('There are variants linked to this product', associated_variant_ids: pm_variant_ids)
    #   end
    # end
    #
    # def update_pm_product(id, attrs)
    #   if (pm_variant_ids = pm_variant_ids(id).empty?)
    #     update(:pack_material_products, id, attrs)
    #     success_response('ok')
    #   else
    #     failed_response('There are variants linked to this product', associated_variant_ids: pm_variant_ids)
    #   end
    # end
    #
    # def pm_variant_ids(id)
    #   DB[:pack_material_product_variants].where(pack_material_product_id: id).all.map { |r| r[:id] }
    # end

    def test_create_pm_product_variant
      product = create_product
      attrs = {
        pack_material_product_id: product[:id],
        reference_size: 'size',
        reference_dimension: 'dim',
        reference_quantity: 'qty'
      }
      actual = repo.create_pm_product_variant(attrs)
      assert actual
      assert repo.exists?(:pack_material_product_variants, id: actual)
      variant = repo.find_hash(:pack_material_product_variants, actual)
      mr_variant = repo.where_hash(:material_resource_product_variants, product_variant_id: variant[:id])
      assert mr_variant
      assert_equal variant[:product_variant_number], mr_variant[:product_variant_number]
      assert_equal product[:matres_sub_type_id], mr_variant[:sub_type_id]
    end

    def test_delete_pm_product_variant
      mr_variant = create_material_resource_product_variant
      assert repo.delete_pm_product_variant(mr_variant[:product_variant_id])
      assert_nil repo.find_hash(:material_resource_product_variants, mr_variant[:id])
    end

    private

    def repo
      PmProductRepo.new
    end
  end
end
