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

    def test_product_code_column_subset
      ConfigRepo.any_instance.stubs(:for_select_material_resource_product_columns).returns([['a', 1], ['a', 2], ['a', 3], ['a', 5], ['a', 6]])
      assert_equal [['a', 1], ['a', 2], ['a', 3]], repo.product_code_column_subset([1, 2, 3])
    end

    def test_find_matres_type
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )

      y = ConfigRepo.new.find_matres_type(type_id)
      assert_instance_of(PackMaterialApp::MatresType, y)
      assert_equal(y.domain_name, 'domain name')
      assert_equal(y.id, type_id)

      DB[:material_resource_types].where(id: type_id).delete
      y = ConfigRepo.new.find_matres_type(type_id)
      assert_nil y

      DB[:material_resource_domains].where(id: dom_id).delete
    end

    def test_delete_matres_sub_type
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        product_table_name: 'pack_material_products',
        variant_table_name: 'variant table name'
      )
      id_1 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name one',
        short_code: 'CN1'
      )
      id_2 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name two',
        short_code: 'CN2'
      )
      id_3 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name three',
        short_code: 'CN3'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )
      sub_id = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id,
        sub_type_name: 'sub type name',
        short_code: 'SC',
        product_code_ids: "{#{id_1},#{id_2},#{id_3}}"
      )
      comm_group_id = DB[:commodity_groups].insert(
        code: 'group',
        description: 'desc'
      )
      comm_id = DB[:commodities].insert(
        commodity_group_id: comm_group_id,
        code: 'AP',
        hs_code: 'AP',
        description: 'desc'
      )
      var_id = DB[:marketing_varieties].insert(
        marketing_variety_code: 'variety'
      )
      prod_1_id = DB[:pack_material_products].insert(
        material_resource_sub_type_id: sub_id,
        commodity_id: comm_id,
        variety_id: var_id,
        product_number: 789456
      )
      prod_2_id = DB[:pack_material_products].insert(
        material_resource_sub_type_id: sub_id,
        commodity_id: comm_id,
        variety_id: var_id,
        product_number: 789457
      )

      x = ConfigRepo.new.delete_matres_sub_type(sub_id)
      refute x.success

      DB[:pack_material_products].where(id: [prod_1_id, prod_2_id]).delete
      x = ConfigRepo.new.delete_matres_sub_type(sub_id)
      assert x.success
      assert_nil ConfigRepo.new.find_matres_sub_type(sub_id)
    end

    def test_product_code_columns
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      id_1 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name one',
        short_code: 'CN1'
      )
      id_2 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name two',
        short_code: 'CN2'
      )
      id_3 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name three',
        short_code: 'CN3'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )
      sub_id = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id,
        sub_type_name: 'sub type name',
        short_code: 'SC',
        product_code_ids: "{#{id_1},#{id_2},#{id_3}}"
      )

      y = ConfigRepo.new.product_code_columns(sub_id)
      assert_equal(y, [["column name one", id_1], ["column name two", id_2], ["column name three", id_3]])
    end

    def test_update_product_code_configuration
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        product_table_name: 'product table name',
        variant_table_name: 'variant table name'
      )
      type_id = DB[:material_resource_types].insert(
        material_resource_domain_id: dom_id,
        type_name: 'type name',
        short_code: 'SC',
        description: 'This is the description field'
      )
      sub_id = DB[:material_resource_sub_types].insert(
        material_resource_type_id: type_id,
        sub_type_name: 'sub type name',
        short_code: 'SC'
      )
      test_res = { chosen_column_ids: [77, 78, 79], columncodes_sorted_ids: [78, 79, 77] }
      x = ConfigRepo.new.update_product_code_configuration(sub_id, test_res)
      assert_equal(true, x.success)

      matres_sub_type = ConfigRepo.new.find_matres_sub_type(sub_id)
      assert_equal(matres_sub_type.product_column_ids.join(','), '77,78,79')
      assert_equal(matres_sub_type.product_code_ids.join(','), '78,79,77')
    end

    def repo
      ConfigRepo.new
    end
  end
end
