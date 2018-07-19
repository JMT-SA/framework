require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

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

      assert_respond_to repo, :find_matres_master_list_item
      assert_respond_to repo, :create_matres_master_list_item
      assert_respond_to repo, :update_matres_master_list_item
      assert_respond_to repo, :delete_matres_master_list_item

      assert_respond_to repo, :find_matres_master_list
      assert_respond_to repo, :create_matres_master_list
      assert_respond_to repo, :update_matres_master_list
      assert_respond_to repo, :delete_matres_master_list
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

    def update_matres_type
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

      attrs = { description: 'This is the updated description', measurement_units: [] }
      ConfigRepo.new.update_matres_type(type_id, attrs)
      assert_equal('This is the updated description', DB[:material_resource_types].where(id: type_id).select(:description))

      each_id = DB[:measurement_units].insert(unit_of_measure: 'each')
      pallets_id = DB[:measurement_units].insert(unit_of_measure: 'pallets')
      bags_id = DB[:measurement_units].insert(unit_of_measure: 'bags')
      attrs = { measurement_units: [each_id, pallets_id, bags_id] }
      ConfigRepo.new.update_matres_type(type_id, attrs)
      x = DB[:measurement_units_for_matres_types]
          .where(material_resource_type_id: type_id)
          .select_map(:measurement_unit_id)

      assert_equal [each_id, pallets_id, bags_id], x
    end

    def test_measurement_units
      DB[:measurement_units].insert(unit_of_measure: 'each') # each_id
      DB[:measurement_units].insert(unit_of_measure: 'pallets') # pallets_id
      DB[:measurement_units].insert(unit_of_measure: 'bags') # bags_id

      y = ConfigRepo.new.measurement_units
      assert_equal y, %w[each pallets bags]

      DB[:measurement_units].delete
      y = ConfigRepo.new.measurement_units
      assert_equal y, []
    end

    def test_matres_type_measurement_units_and_ids
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
      each_id = DB[:measurement_units].insert(unit_of_measure: 'each')
      pallets_id = DB[:measurement_units].insert(unit_of_measure: 'pallets')
      bags_id = DB[:measurement_units].insert(unit_of_measure: 'bags')
      DB[:measurement_units_for_matres_types].insert(
        material_resource_type_id: type_id,
        measurement_unit_id: each_id
      )
      DB[:measurement_units_for_matres_types].insert(
        material_resource_type_id: type_id,
        measurement_unit_id: pallets_id
      )
      DB[:measurement_units_for_matres_types].insert(
        material_resource_type_id: type_id,
        measurement_unit_id: bags_id
      )
      y = ConfigRepo.new.matres_type_measurement_units(type_id)
      assert_equal y, %w[each pallets bags]

      y = ConfigRepo.new.matres_type_measurement_unit_ids(type_id)
      assert_equal y, [each_id, pallets_id, bags_id]

      DB[:measurement_units_for_matres_types].where(material_resource_type_id: type_id).delete
      y = ConfigRepo.new.matres_type_measurement_units(type_id)
      assert_equal y, []
      y = ConfigRepo.new.matres_type_measurement_unit_ids(type_id)
      assert_equal y, []
    end

    def test_create_matres_type_unit
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

      ConfigRepo.new.create_matres_type_unit(type_id, 'test unit')
      unit_id = DB[:measurement_units].where(unit_of_measure: 'test unit').select_map(:id)
      refute_nil unit_id
      link_id = DB[:measurement_units_for_matres_types].where(material_resource_type_id: type_id).select_map(:measurement_unit_id)
      assert_equal link_id, unit_id
    end

    def test_add_matres_type_unit
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
      each_id = DB[:measurement_units].insert(unit_of_measure: 'each')
      DB[:measurement_units].insert(unit_of_measure: 'pallets') # pallets_id
      DB[:measurement_units].insert(unit_of_measure: 'bags') # bags_id

      ConfigRepo.new.add_matres_type_unit(type_id, 'each')
      link_id = DB[:measurement_units_for_matres_types].where(
        material_resource_type_id: type_id,
        measurement_unit_id: each_id
      )
      refute_nil link_id

      assert_raises do
        PackMaterialApp::ConfigRepo.new.add_matres_type_unit(type_id, 'does not exist')
      end
    end

    def test_delete_matres_sub_type
      dom_id = DB[:material_resource_domains].insert(
        domain_name: 'domain name',
        product_table_name: 'pack_material_products',
        variant_table_name: 'variant table name'
      )
      id1 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name one',
        short_code: 'CN1'
      )
      id2 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name two',
        short_code: 'CN2'
      )
      id3 = DB[:material_resource_product_columns].insert(
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
        product_code_ids: "{#{id1},#{id2},#{id3}}"
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
      prod_id1 = DB[:pack_material_products].insert(
        material_resource_sub_type_id: sub_id,
        commodity_id: comm_id,
        variety_id: var_id,
        product_number: 789_456
      )
      prod_id2 = DB[:pack_material_products].insert(
        material_resource_sub_type_id: sub_id,
        commodity_id: comm_id,
        variety_id: var_id,
        product_number: 789_457
      )

      x = ConfigRepo.new.delete_matres_sub_type(sub_id)
      refute x.success

      DB[:pack_material_products].where(id: [prod_id1, prod_id2]).delete
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
      id1 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name one',
        short_code: 'CN1'
      )
      id2 = DB[:material_resource_product_columns].insert(
        material_resource_domain_id: dom_id,
        column_name: 'column name two',
        short_code: 'CN2'
      )
      id3 = DB[:material_resource_product_columns].insert(
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
        product_code_ids: "{#{id1},#{id2},#{id3}}"
      )

      y = ConfigRepo.new.product_code_columns(sub_id)
      assert_equal(y, [['column name one', id1], ['column name two', id2], ['column name three', id3]])
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

    def test_sub_type_master_list_items
      skip 'still todo'
      sub_id = 1
      y = ConfigRepo.new.sub_type_master_list_items(sub_id)
      p y
    end

    def repo
      ConfigRepo.new
    end
  end
end
