require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')
require 'faker'

module PackMaterialApp
  class TestConfigRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_domains
      assert_respond_to repo, :for_select_matres_types
      assert_respond_to repo, :for_select_matres_sub_types
      assert_respond_to repo, :for_select_material_resource_product_columns
      assert_respond_to repo, :for_select_units
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

      attrs = { description: 'This is the updated description', measurement_units: [] }
      repo.update_matres_type(type_id, attrs)
      assert_equal(
        'This is the updated description',
        DB[:material_resource_types].where(id: type_id).first[:description]
      )

      units = add_std_measurement_units
      unit_list = [units[:each_id], units[:pallets_id], units[:bags_id]]
      attrs = { measurement_units: unit_list }
      repo.update_matres_type(type_id, attrs)
      x = DB[:measurement_units_for_matres_types]
          .where(material_resource_type_id: type_id)
          .select_map(:measurement_unit_id)

      assert_equal unit_list, x

      # matres_type_with_products
      ConfigRepo.any_instance.stubs(:matres_type_has_products).returns(true)
      attrs = { type_name: 'new type name', short_code: 'TT' }
      repo.update_matres_type(type_id, attrs)
      type = DB[:material_resource_types].where(id: type_id).first
      assert_equal('new type name', type[:type_name])
      assert_equal('TN', type[:short_code])
    end

    def test_measurement_units
      add_std_measurement_units
      y = repo.measurement_units
      assert_equal y, %w[each pallets bags]

      DB[:measurement_units].delete
      y = repo.measurement_units
      assert_equal y, []
    end

    def test_matres_type_measurement_units_and_ids
      type_id = @fixed_table_set[:matres_types][:sc][:id]
      units = add_std_measurement_units
      unit_list = [units[:each_id], units[:pallets_id], units[:bags_id]]
      DB[:measurement_units_for_matres_types].insert(
        material_resource_type_id: type_id,
        measurement_unit_id: units[:each_id]
      )
      DB[:measurement_units_for_matres_types].insert(
        material_resource_type_id: type_id,
        measurement_unit_id: units[:pallets_id]
      )
      DB[:measurement_units_for_matres_types].insert(
        material_resource_type_id: type_id,
        measurement_unit_id: units[:bags_id]
      )
      assert_equal %w[each pallets bags], repo.matres_type_measurement_units(type_id)
      assert_equal unit_list, repo.matres_type_measurement_unit_ids(type_id)

      DB[:measurement_units_for_matres_types].where(material_resource_type_id: type_id).delete
      assert_equal [], repo.matres_type_measurement_units(type_id)
      assert_equal [], repo.matres_type_measurement_unit_ids(type_id)
    end

    def test_create_matres_type_unit
      type_id = @fixed_table_set[:matres_types][:sc][:id]
      repo.create_matres_type_unit(type_id, 'test unit')
      unit_id = DB[:measurement_units].where(unit_of_measure: 'test unit').select_map(:id)
      refute_nil unit_id
      link_id = DB[:measurement_units_for_matres_types].where(material_resource_type_id: type_id)
                                                       .select_map(:measurement_unit_id)
      assert_equal link_id, unit_id
    end

    def test_add_matres_type_unit
      type_id = @fixed_table_set[:matres_types][:sc][:id]
      each_id = add_measurement_unit('each')
      repo.add_matres_type_unit(type_id, 'each')
      link_id = DB[:measurement_units_for_matres_types].where(
        material_resource_type_id: type_id,
        measurement_unit_id: each_id
      )
      refute_nil link_id
      assert_raises do
        repo.add_matres_type_unit(type_id, 'does not exist')
      end
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

      DB[:pack_material_products].where(id: [first[:matres_product_id], second[:matres_product_id]]).delete
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
        material_resource_domain_id: other_dom_id,
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
      assert_raises(NoMethodError) {
        repo.product_variant_columns(sub_id)
      }
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

    def test_sub_type_master_list_items
      skip 'still todo'
    end

    # def sub_type_master_list_items(sub_type_id)
    #   DB[get_dataminer_report('matres_prodcol_sub_type_list_items.yml').sql].where(sub_type_id: sub_type_id)
    #
    # end
    #
    # def for_select_sub_type_master_list_items(sub_type_id, product_column)
    #   sub_type_master_list_items(sub_type_id).map do |r|
    #     if r[:column_name] == product_column.to_s && r[:active]
    #       [(r[:short_code] + (r[:long_name] ? ' - ' + r[:long_name] : '')).to_s, r[:id]]
    #     end
    #   end.compact
    # end
    #
    # def get_dataminer_report(file_name)
    #   path = File.join(ENV['ROOT'], 'grid_definitions', 'dataminer_queries', file_name.sub('.yml', '') << '.yml')
    #   rpt_hash = Crossbeams::Dataminer::YamlPersistor.new(path)
    #   Crossbeams::Dataminer::Report.load(rpt_hash)
    # end

    def test_matres_sub_type_has_products
      product_set = create_product
      assert repo.matres_sub_type_has_products(product_set[:matres_sub_type_id])

      DB[:pack_material_products].where(id: product_set[:matres_product_id]).delete
      refute repo.matres_sub_type_has_products(product_set[:matres_sub_type_id])
    end

    def test_matres_type_has_products
      product_set = create_product
      assert repo.matres_type_has_products(product_set[:matres_type_id])

      DB[:pack_material_products].where(id: product_set[:matres_product_id]).delete
      refute repo.matres_type_has_products(product_set[:matres_type_id])
    end

    private

    def repo
      ConfigRepo.new
    end

    def test_factories
      create_sub_type
      create_product_column
      create_product
      create_other_domain
      create_matres_type
    end

    def create_product(opts = {})
      sub_type = repo.find_hash(:material_resource_sub_types, @fixed_table_set[:matres_sub_types][:sc][:id])
      sub_id = sub_type[:id]
      type_id = sub_type[:material_resource_type_id]
      default = { material_resource_sub_type_id: sub_id,
                  unit: 'unit',
                  brand_1: 'brand',
                  style: 'style' }
      prod_id = DB[:pack_material_products].insert(default.merge(opts))
      {
        matres_type_id: type_id,
        matres_sub_type_id: sub_id,
        matres_product_id: prod_id
      }
    end

    def create_other_domain
      DB[:material_resource_domains].insert(
        domain_name: 'Other Domain',
        product_table_name: 'other_products',
        variant_table_name: 'other_product_variants'
      )
    end

    def create_matres_type(opts = {})
      default = {
        material_resource_domain_id: @fixed_table_set[:domain_id],
        type_name: Faker::Company.name.to_s,
        short_code: 'PZ',
        description: 'Material used to palletize'
      }
      DB[:material_resource_types].insert(default.merge(opts))
    end

    def create_sub_type(opts = {})
      sql = <<~SQL
        SELECT id FROM material_resource_product_columns
        WHERE column_name IN ('unit', 'style', 'brand_1', 'reference_size', 'reference_dimension', 'reference_quantity')
      SQL
      prod_col_ids = DB[sql].select_map
      prod_code_ids = prod_col_ids[0..2]
      default = {
        material_resource_type_id: @fixed_table_set[:matres_types][:sc][:id],
        sub_type_name: Faker::Company.name.to_s,
        short_code: Faker::Lorem.unique.word,
        active: true,
        product_code_ids: "{#{prod_code_ids.join(',')}}",
        product_column_ids: "{#{prod_col_ids.join(',')}}"
      }
      DB[:material_resource_sub_types].insert(default.merge(opts))
    end

    def add_measurement_unit(unit_name)
      DB[:measurement_units].insert(unit_of_measure: unit_name)
    end

    def add_std_measurement_units
      {
        each_id: add_measurement_unit('each'),
        pallets_id: add_measurement_unit('pallets'),
        bags_id: add_measurement_unit('bags')
      }
    end

    def create_product_column(opts = {})
      dom_id = @fixed_table_set[:domain_id]
      default = {
        material_resource_domain_id: dom_id,
        column_name: Faker::Company.unique.name,
        short_code: Faker::Lorem.unique.word
      }
      DB[:material_resource_product_columns].insert(default.merge(opts))
    end
  end
end
