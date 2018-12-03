require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestConfigRepo < MiniTestWithHooks
    include ConfigFactory
    include MasterfilesApp::PartyFactory
    include PmProductFactory

    def test_for_selects
      assert_respond_to repo, :for_select_domains
      assert_respond_to repo, :for_select_matres_types
      assert_respond_to repo, :for_select_matres_sub_types
      assert_respond_to repo, :for_select_material_resource_product_columns
      assert_respond_to repo, :for_select_matres_product_variants
      assert_respond_to repo, :for_select_matres_product_variant_party_roles
    end

    def crud_call_for(key)
      assert_respond_to repo, :"find_#{key}"
      assert_respond_to repo, :"create_#{key}"
      assert_respond_to repo, :"update_#{key}"
      assert_respond_to repo, :"delete_#{key}"
    end

    def test_crud_call_responses
      crud_call_for('matres_type')
      crud_call_for('matres_sub_type')
      crud_call_for('pm_product')
      crud_call_for('matres_master_list_item')
      crud_call_for('matres_master_list')
      crud_call_for('matres_product_variant')
      crud_call_for('matres_product_variant_party_role')
    end

    def test_product_code_column_subset
      ConfigRepo.any_instance
                .stubs(:for_select_material_resource_product_columns)
                .returns([['a', 1], ['a', 2], ['a', 3], ['a', 5], ['a', 6]])
      assert_equal [['a', 1], ['a', 2], ['a', 3]], repo.product_code_column_subset([1, 2, 3])
    end

    def test_for_select_configured_sub_types
      # First Type: one configured, one invalid sub type
      type_id1 = create_matres_type(short_code: 'T1')
      sub_id1 = create_sub_type(
        material_resource_type_id: type_id1,
        sub_type_name: '1 sub type one'
      )
      sub_id2 = create_sub_type(
        material_resource_type_id: type_id1,
        sub_type_name: 'INVALID sub type',
        product_code_ids: nil
      )
      # Second Type: one configured, one inactive sub type
      type_id2 = create_matres_type(short_code: 'T2')
      sub_id3 = create_sub_type(
        material_resource_type_id: type_id2,
        sub_type_name: '2 sub type one'
      )
      sub_id4 = create_sub_type(
        material_resource_type_id: type_id2,
        sub_type_name: 'INACTIVE sub type',
        active: false
      )
      # Create sub type from other domain
      dom_id2 = create_other_domain
      other_type_id = create_matres_type(
        material_resource_domain_id: dom_id2,
        short_code: 'OTHER_DOMAIN'
      )
      create_sub_type(
        material_resource_type_id: other_type_id
      )

      y = repo.for_select_configured_sub_types(PackMaterialApp::DOMAIN_NAME)
      expected = { 'T1' => [['1 sub type one', sub_id1]], 'T2' => [['2 sub type one', sub_id3]] }

      refute(y['T1'].any? { |s| s.first == 'INVALID sub type' })
      refute(y['T1'].any? { |s| s.last == sub_id2 })
      refute(y['T2'].any? { |s| s.first == 'INACTIVE sub type' })
      refute(y['T2'].any? { |s| s.last == sub_id4 })
      assert_nil y['OTHER_DOMAIN']

      assert_equal y['T1'], expected['T1']
      assert_equal y['T2'], expected['T2']
    end

    def test_find_matres_type
      type_id = create_matres_type

      instance = repo.find_matres_type(type_id)
      assert_instance_of(PackMaterialApp::MatresType, instance)
      assert_equal PackMaterialApp::DOMAIN_NAME, instance.domain_name
      assert_equal(instance.id, type_id)

      DB[:material_resource_types].where(id: type_id).delete
      instance = repo.find_matres_type(type_id)
      assert_nil instance
    end

    def test_update_matres_type
      type_id = create_matres_type(
        type_name: 'type name',
        short_code: 'TN',
        description: 'This is the description field'
      )

      attrs = { description: 'This is the updated description' }
      repo.update_matres_type(type_id, attrs)
      assert_equal(
        'This is the updated description',
        DB[:material_resource_types].where(id: type_id).first[:description]
      )

      # matres_type_with_products
      ConfigRepo.any_instance.stubs(:matres_type_has_products).returns(true)
      attrs = { type_name: 'new type name', short_code: 'TT' }
      repo.update_matres_type(type_id, attrs)
      type = DB[:material_resource_types].where(id: type_id).first
      assert_equal('new type name', type[:type_name])
      assert_equal('TN', type[:short_code])
    end

    def test_update_matres_sub_type
      sub_id = create_sub_type(
        sub_type_name: 'sub type name',
        short_code: 'SN'
      )

      attrs = { sub_type_name: 'new sub name' }
      repo.update_matres_sub_type(sub_id, attrs)
      assert_equal('new sub name', DB[:material_resource_sub_types].where(id: sub_id).first[:sub_type_name])

      # matres_sub_type_with_products
      ConfigRepo.any_instance.stubs(:matres_sub_type_has_products).returns(true)
      attrs = { sub_type_name: 'new sub name', short_code: 'TT' }
      repo.update_matres_sub_type(sub_id, attrs)
      sub_type = DB[:material_resource_sub_types].where(id: sub_id).first
      assert_equal('new sub name', sub_type[:sub_type_name])
      assert_equal('SN', sub_type[:short_code])
    end

    def test_delete_matres_sub_type
      first = create_product
      second = create_product(unit: 'units',
                              brand_1: 'brands',
                              style: 'styles')

      x = repo.delete_matres_sub_type(first[:matres_sub_type_id])
      refute x.success

      DB[:pack_material_products].where(id: [first[:id], second[:id]]).delete
      x = repo.delete_matres_sub_type(first[:matres_sub_type_id])
      assert x.success
      assert_nil repo.find_matres_sub_type(first[:matres_sub_type_id])
    end

    def test_product_variant_columns
      id1 = create_product_column
      id2 = create_product_column
      id3 = create_product_column
      other_dom_id = create_other_domain
      create_product_column(
        material_resource_domain_id: other_dom_id
      )
      sub_id = create_sub_type(
        product_code_ids: "{#{id1}}",
        product_column_ids: "{#{id1},#{id2},#{id3}}"
      )

      variant_columns = repo.product_variant_columns(sub_id)
      assert(variant_columns.none? { |r| r.last == id1 })
      assert(variant_columns.any? { |r| r.last == id2 })
      assert(variant_columns.any? { |r| r.last == id3 })

      DB[:material_resource_sub_types].where(id: sub_id).delete
      assert_raises(NoMethodError) { repo.product_variant_columns(sub_id) }
    end

    def test_product_code_columns
      id1 = create_product_column
      id2 = create_product_column
      id3 = create_product_column
      sub_id = create_sub_type(
        product_code_ids: "{#{id1},#{id2},#{id3}}"
      )

      code_columns = repo.product_code_columns(sub_id)
      assert(code_columns.any? { |r| r.last == id1 })
      assert(code_columns.any? { |r| r.last == id2 })
      assert(code_columns.any? { |r| r.last == id3 })
    end

    def test_update_product_code_configuration
      sub_id = create_sub_type
      test_res = { chosen_column_ids: [77, 78, 79], columncodes_sorted_ids: [78, 79, 77] }
      x = repo.update_product_code_configuration(sub_id, test_res)
      assert_equal(true, x.success)

      matres_sub_type = repo.find_matres_sub_type(sub_id)
      assert_equal(matres_sub_type.product_column_ids.join(','), '77,78,79')
      assert_equal(matres_sub_type.product_code_ids.join(','), '78,79,77')
    end

    def test_for_select_sub_type_master_list_items
      list = create_matres_master_list
      3.times do
        create_matres_master_list_item(material_resource_master_list_id: list[:id])
      end
      create_matres_master_list_item(material_resource_master_list_id: list[:id], active: false)
      prod_col_id = list[:material_resource_product_column_id]
      prod = repo.where_hash(:material_resource_product_columns, id: prod_col_id)
      sub_type_id = @fixed_table_set[:matres_sub_types][:sc][:id]
      result = repo.for_select_sub_type_master_list_items(sub_type_id, prod[:column_name])
      assert_equal 3, result.count
    end

    def test_product_column_name
      result = repo.product_column_by_name('unit')
      assert result.is_a?(PackMaterialApp::MatresProductColumn)
      assert_equal 'unit', result.column_name
    end

    def test_matres_sub_type_master_list_items
      list = create_matres_master_list
      3.times do
        create_matres_master_list_item(material_resource_master_list_id: list[:id])
      end

      sub_type_id = @fixed_table_set[:matres_sub_types][:sc][:id]
      prod_col_id = list[:material_resource_product_column_id]
      result = repo.matres_sub_type_master_list_items(sub_type_id, prod_col_id)
      assert_equal 3, result.count

      result = repo.matres_sub_type_master_list_items(sub_type_id, (prod_col_id + 1))
      assert_equal 0, result.count
    end

    def test_matres_sub_type_has_products
      product_set = create_product
      assert repo.matres_sub_type_has_products(product_set[:matres_sub_type_id])

      DB[:pack_material_products].where(id: product_set[:id]).delete
      refute repo.matres_sub_type_has_products(product_set[:matres_sub_type_id])
    end

    def test_matres_type_has_products
      product_set = create_product
      assert repo.matres_type_has_products(product_set[:matres_type_id])

      DB[:pack_material_products].where(id: product_set[:id]).delete
      refute repo.matres_type_has_products(product_set[:matres_type_id])
    end

    def test_create_matres_product_variant_party_role
      variant = create_material_resource_product_variant
      supplier = create_supplier
      customer = create_customer
      attrs = {
        supplier_id: nil,
        customer_id: nil,
        material_resource_product_variant_id: variant[:id],
        supplier_lead_time: 12
      }

      result = repo.create_matres_product_variant_party_role(attrs.merge(supplier_id: supplier[:id], customer_id: customer[:id]))
      refute result.success
      assert_equal 'Can not assign both customer and supplier', result.errors[:base][0]

      result = repo.create_matres_product_variant_party_role(attrs)
      refute result.success
      assert_equal 'Must have customer or supplier', result.errors[:base][0]

      result = repo.create_matres_product_variant_party_role(attrs.merge(supplier_id: supplier[:id]))
      assert result.success
      result = repo.create_matres_product_variant_party_role(attrs.merge(supplier_id: supplier[:id]))
      refute result.success
      assert_equal 'Supplier already exists', result.errors[:base][0]

      result = repo.create_matres_product_variant_party_role(attrs.merge(customer_id: customer[:id]))
      assert result.success
      result = repo.create_matres_product_variant_party_role(attrs.merge(customer_id: customer[:id]))
      refute result.success
      assert_equal 'Customer already exists', result.errors[:base][0]
    end

    def test_find_product_variant_party_role
      customer = create_customer
      role_link = create_matres_product_variant_party_role(AppConst::ROLE_CUSTOMER, customer_id: customer[:id])

      full_party_role = repo.find_product_variant_party_role(role_link[:id])
      assert full_party_role.is_a?(MatresProductVariantPartyRole)
      refute full_party_role.supplier?

      expected_name = DB["SELECT fn_party_role_name(#{customer[:party_role_id]}) as party_name"].first
      assert_equal expected_name[:party_name], full_party_role.party_name
    end

    def test_link_alternatives
      alternative_ids = []
      2.times do
        alternative_ids << create_material_resource_product_variant[:id]
      end
      variant = create_material_resource_product_variant
      repo.link_alternatives(variant[:id], alternative_ids)
      assert repo.exists?(:alternative_material_resource_product_variants, alternative_id: alternative_ids[0])
      assert repo.exists?(:alternative_material_resource_product_variants, alternative_id: alternative_ids[1])
    end

    def test_link_co_use_product_codes
      co_use_ids = []
      2.times do
        co_use_ids << create_material_resource_product_variant[:id]
      end
      variant = create_material_resource_product_variant
      repo.link_co_use_product_codes(variant[:id], co_use_ids)
      assert repo.exists?(:co_use_material_resource_product_variants, co_use_id: co_use_ids[0])
      assert repo.exists?(:co_use_material_resource_product_variants, co_use_id: co_use_ids[1])
    end

    def test_factories
      create_sub_type
      create_product_column
      create_product
      create_other_domain
      create_matres_type
    end

    private

    def repo
      ConfigRepo.new
    end
  end
end
