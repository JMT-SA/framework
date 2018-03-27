require File.join(File.expand_path('../../../../../test', __FILE__), 'test_helper')

module PackMaterialApp
  class TestConfigRepo < MiniTestWithHooks

    def test_for_selects
      assert_respond_to repo, :for_select_domains
      assert_respond_to repo, :for_select_matres_types
      assert_respond_to repo, :for_select_matres_sub_types
    end

    def test_crud_calls
      assert_respond_to repo, :find_matres_type
      assert_respond_to repo, :create_matres_type
      assert_respond_to repo, :update_matres_type
      assert_respond_to repo, :delete_matres_type

      assert_respond_to repo, :find_matres_sub_type
      assert_respond_to repo, :create_matres_sub_type
      assert_respond_to repo, :update_matres_sub_type
      assert_respond_to repo, :delete_matres_sub_type

      assert_respond_to repo, :find_pm_product
      assert_respond_to repo, :create_pm_product
      assert_respond_to repo, :update_pm_product
      assert_respond_to repo, :delete_pm_product
    end

    def test_find_matres_type
      # assert_nil repo.find_matres_type(1)

      # DB[:material_resource_sub_types]
    end

    def test_non_variant_column_subset
      ConfigRepo.any_instance.stubs(:for_select_material_resource_product_columns).returns([['a', 1], ['a', 2], ['a', 3], ['a', 5], ['a', 6]])
      assert_equal [['a', 1], ['a', 2], ['a', 3]], repo.non_variant_columns_subset([1, 2, 3, 4])
    end

    def test_variant_column_subset
      ConfigRepo.any_instance.stubs(:for_select_material_resource_product_columns).returns([['a', 1], ['a', 2], ['a', 3], ['a', 5], ['a', 6]])
      assert_equal [['a', 1], ['a', 3]], repo.variant_columns_subset([1, 3, 4])
    end

    def repo
      ConfigRepo.new
    end
  end
end
