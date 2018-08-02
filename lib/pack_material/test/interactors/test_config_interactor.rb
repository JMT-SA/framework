# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module PackMaterialApp
  class TestConfigInteractor < Minitest::Test
    def test_repo
      x = interactor.send(:repo)
      assert x.is_a?(PackMaterialApp::ConfigRepo)
    end

    # MATRES TYPE
    def test_matres_type
      ConfigRepo.any_instance.stubs(:find_matres_type).returns(fake_matres_type)
      x = interactor.send(:matres_type)
      assert x.is_a?(MatresType)

      x = interactor.send(:matres_type, true)
      assert x.is_a?(MatresType)
    end

    def test_validate_matres_type_params
      test_attrs = matres_type_attrs
      x = interactor.send(:validate_matres_type_params, test_attrs)
      assert_empty x.errors

      # optional(:id).filled(:int?)
      x = interactor.send(:validate_matres_type_params, test_attrs.reject { |k| k == :id })
      assert_empty x. errors

      x = interactor.send(:validate_matres_type_params, test_attrs.merge(id: 'name'))
      assert_equal(['must be an integer'], x.errors[:id])

      # required(:material_resource_domain_id).filled(:int?)
      x = interactor.send(:validate_matres_type_params, test_attrs.reject { |k| k == :material_resource_domain_id })
      assert_equal(['is missing'], x.errors[:material_resource_domain_id])

      x = interactor.send(:validate_matres_type_params, test_attrs.merge(material_resource_domain_id: nil))
      assert_equal(['must be filled'], x.errors[:material_resource_domain_id])

      x = interactor.send(:validate_matres_type_params, test_attrs.merge(material_resource_domain_id: 'name'))
      assert_equal(['must be an integer'], x.errors[:material_resource_domain_id])

      # required(:type_name).filled(:str?)
      x = interactor.send(:validate_matres_type_params, test_attrs.reject { |k| k == :type_name })
      assert_equal(['is missing'], x.errors[:type_name])

      x = interactor.send(:validate_matres_type_params, test_attrs.merge(type_name: nil))
      assert_equal(['must be filled'], x.errors[:type_name])

      x = interactor.send(:validate_matres_type_params, test_attrs.merge(type_name: 1))
      assert_equal(['must be a string'], x.errors[:type_name])
    end

    def test_create_matres_type
      ConfigRepo.any_instance.stubs(:create_matres_type).returns(id: 1)
      ConfigRepo.any_instance.stubs(:find_matres_type).returns(fake_matres_type)

      invalid_attrs = matres_type_attrs.merge(type_name: nil)
      x = interactor.create_matres_type(invalid_attrs)
      assert_equal false, x.success
      assert_equal 'Validation error', x.message

      x = interactor.create_matres_type(matres_type_attrs.reject { |k| k == :id })
      assert x.success
      assert_equal('Created type Retail', x.message)
      assert_instance_of(MatresType, x.instance)
    end

    def test_update_matres_type
      # Fails on invalid update
      x = interactor.update_matres_type(1, invalid_matres_type_attrs)
      assert_equal(false, x.success)

      # Updates successfully
      ConfigRepo.any_instance.stubs(:update_matres_type).returns(true)
      ConfigInteractor.any_instance.stubs(:matres_type).returns(fake_matres_type)
      update_attrs = matres_type_attrs.merge(type_name: 'Retailers')
      x = interactor.update_matres_type(1, update_attrs)
      expected = interactor.success_response('Updated type Retail', fake_matres_type)
      assert_equal(expected, x)
      assert x.success

      # Gives validation failed response on fail
      x = interactor.update_matres_type(1, invalid_matres_type_attrs)
      res = interactor.send(:validate_matres_type_params, invalid_matres_type_attrs)
      expected = interactor.validation_failed_response(res)
      assert_equal(expected, x)
    end

    def test_delete_matres_type
      ConfigRepo.any_instance.stubs(:delete_matres_type).returns(true)
      ConfigInteractor.any_instance.stubs(:matres_type).returns(fake_matres_type)
      x = interactor.delete_matres_type(1)
      assert_equal 'Deleted type Retail', x.message
      assert x.success
    end

    def matres_type_attrs
      {
        id: 1,
        material_resource_domain_id: 1,
        type_name: 'Retail',
        domain_name: 'Pack Material',
        short_code: 'RT',
        description: 'Stock for Retail'
      }
    end

    def test_validate_matres_unit_params
      test_attrs = { unit_of_measure: 'each', other: 'new unit' }
      # required(:unit_of_measure).filled(:str?)
      x = interactor.send(:validate_matres_unit_params, test_attrs.reject { |k| k == :unit_of_measure })
      assert_equal(['is missing'], x.errors[:unit_of_measure])

      x = interactor.send(:validate_matres_unit_params, test_attrs.merge(unit_of_measure: nil))
      assert_equal(['must be filled'], x.errors[:unit_of_measure])

      x = interactor.send(:validate_matres_unit_params, test_attrs.merge(unit_of_measure: 1))
      assert_equal(['must be a string'], x.errors[:unit_of_measure])
    end

    def test_add_a_matres_unit
      ConfigInteractor.any_instance.stubs(:create_matres_unit).returns(true)
      ConfigInteractor.any_instance.stubs(:add_matres_unit).returns(false)

      params = { other: 'new unit', unit_of_measure: 'other' }
      x = interactor.add_a_matres_unit(1, params)
      assert_equal true, x

      params = { unit_of_measure: 'thing' }
      x = interactor.add_a_matres_unit(1, params)
      assert_equal false, x
    end

    def test_create_matres_unit
      ConfigRepo.any_instance.stubs(:create_matres_type_unit).returns(true)
      params = { other: 'new unit' }

      x = interactor.create_matres_unit(1, params)
      expected = interactor.success_response('Created unit new unit')
      assert_equal(expected, x)
      assert x.success

      ConfigRepo.any_instance.stubs(:create_matres_type_unit).raises(Sequel::UniqueConstraintViolation)
      params = { other: 'new unit' }

      x = interactor.create_matres_unit(1, params)
      expected = interactor.validation_failed_response(OpenStruct.new(messages: { other: ['This unit already exists'] }))
      assert_equal(expected, x)
      refute x.success
    end

    def test_add_matres_unit
      ConfigRepo.any_instance.stubs(:add_matres_type_unit).returns(true)
      ConfigInteractor.any_instance.stubs(:matres_type).returns(fake_matres_type)
      params = { unit_of_measure: 'new unit' }

      x = interactor.add_matres_unit(1, params)
      expected = interactor.success_response("Unit was added to #{fake_matres_type.type_name}", fake_matres_type)
      assert_equal expected, x
      assert x.success

      ConfigRepo.any_instance.stubs(:add_matres_type_unit).raises(Sequel::UniqueConstraintViolation)
      params = { unit_of_measure: 'new unit' }

      x = interactor.add_matres_unit(1, params)
      expected = interactor.validation_failed_response(OpenStruct.new(messages: { unit_of_measure: ['This unit is already assigned'] }))
      assert_equal expected, x
      refute x.success
    end

    def fake_matres_type
      MatresType.new(matres_type_attrs)
    end

    def invalid_matres_type_attrs
      matres_type_attrs.merge(type_name: nil)
    end

    # MATRES SUB TYPE
    def test_matres_sub_type
      ConfigRepo.any_instance.stubs(:find_matres_sub_type).returns(fake_matres_sub_type)
      x = interactor.send(:matres_sub_type)
      assert x.is_a?(MatresSubType)

      x = interactor.send(:matres_sub_type, true)
      assert x.is_a?(MatresSubType)
    end

    def test_validate_matres_sub_type_params
      test_attrs = matres_sub_type_attrs
      x = interactor.send(:validate_matres_sub_type_params, test_attrs)
      assert_empty x.errors

      # optional(:id).filled(:int?)
      x = interactor.send(:validate_matres_sub_type_params, test_attrs.reject { |k| k == :id })
      assert_empty x. errors

      x = interactor.send(:validate_matres_sub_type_params, test_attrs.merge(id: 'name'))
      assert_equal(['must be an integer'], x.errors[:id])

      # required(:material_resource_type_id).filled(:int?)
      x = interactor.send(:validate_matres_sub_type_params, test_attrs.reject { |k| k == :material_resource_type_id })
      assert_equal(['is missing'], x.errors[:material_resource_type_id])

      x = interactor.send(:validate_matres_sub_type_params, test_attrs.merge(material_resource_type_id: nil))
      assert_equal(['must be filled'], x.errors[:material_resource_type_id])

      x = interactor.send(:validate_matres_sub_type_params, test_attrs.merge(material_resource_type_id: 'name'))
      assert_equal(['must be an integer'], x.errors[:material_resource_type_id])

      # required(:sub_type_name).filled(:str?)
      x = interactor.send(:validate_matres_sub_type_params, test_attrs.reject { |k| k == :sub_type_name })
      assert_equal(['is missing'], x.errors[:sub_type_name])

      x = interactor.send(:validate_matres_sub_type_params, test_attrs.merge(sub_type_name: nil))
      assert_equal(['must be filled'], x.errors[:sub_type_name])

      x = interactor.send(:validate_matres_sub_type_params, test_attrs.merge(sub_type_name: 1))
      assert_equal(['must be a string'], x.errors[:sub_type_name])

      # required(:short_code).filled(:str?)
      x = interactor.send(:validate_matres_sub_type_params, test_attrs.reject { |k| k == :short_code })
      assert_equal(['is missing'], x.errors[:short_code])

      x = interactor.send(:validate_matres_sub_type_params, test_attrs.merge(short_code: nil))
      assert_equal(['must be filled'], x.errors[:short_code])

      x = interactor.send(:validate_matres_sub_type_params, test_attrs.merge(short_code: 1))
      assert_equal(['must be a string'], x.errors[:short_code])
    end

    def test_validate_matres_sub_type_config_params
      test_attrs = {
        id: 1,
        product_code_separator: '_',
        has_suppliers: true,
        has_marketers: true,
        has_retailers: true
      }
      # optional(:id).filled(:int?)
      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.reject { |k| k == :id })
      assert_empty x. errors

      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.merge(id: 'name'))
      assert_equal(['must be an integer'], x.errors[:id])

      # required(:product_code_separator).filled(:str?)
      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.reject { |k| k == :product_code_separator })
      assert_equal(['is missing'], x.errors[:product_code_separator])

      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.merge(product_code_separator: nil))
      assert_equal(['must be filled'], x.errors[:product_code_separator])

      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.merge(product_code_separator: 1))
      assert_equal(['must be a string'], x.errors[:product_code_separator])

      # required(:has_suppliers).filled(:bool?)
      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.reject { |k| k == :has_suppliers })
      assert_equal(['is missing'], x.errors[:has_suppliers])

      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.merge(has_suppliers: nil))
      assert_equal(['must be filled'], x.errors[:has_suppliers])

      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.merge(has_suppliers: 'something'))
      assert_equal(['must be boolean'], x.errors[:has_suppliers])
      # required(:has_marketers).filled(:bool?)
      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.reject { |k| k == :has_marketers })
      assert_equal(['is missing'], x.errors[:has_marketers])

      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.merge(has_marketers: nil))
      assert_equal(['must be filled'], x.errors[:has_marketers])

      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.merge(has_marketers: 'something'))
      assert_equal(['must be boolean'], x.errors[:has_marketers])
      # required(:has_retailers).filled(:bool?)
      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.reject { |k| k == :has_retailers })
      assert_equal(['is missing'], x.errors[:has_retailers])

      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.merge(has_retailers: nil))
      assert_equal(['must be filled'], x.errors[:has_retailers])

      x = interactor.send(:validate_matres_sub_type_config_params, test_attrs.merge(has_retailers: 'something'))
      assert_equal(['must be boolean'], x.errors[:has_retailers])
    end

    def test_create_matres_sub_type
      ConfigRepo.any_instance.stubs(:create_matres_sub_type).returns(id: 1)
      ConfigInteractor.any_instance.stubs(:matres_sub_type).returns(fake_matres_sub_type)

      x = interactor.create_matres_sub_type(invalid_matres_sub_type_attrs)
      assert_equal false, x.success
      assert_equal 'Validation error', x.message

      x = interactor.create_matres_sub_type(matres_sub_type_attrs)
      assert x.success
      assert_equal 'Created sub type Bag Fruit', x.message
      assert_instance_of MatresSubType, x.instance
    end

    def test_update_matres_sub_type
      ConfigRepo.any_instance.stubs(:update_matres_sub_type).returns(fake_matres_sub_type)
      ConfigInteractor.any_instance.stubs(:matres_sub_type).returns(fake_matres_sub_type)

      x = interactor.update_matres_sub_type(1, invalid_matres_sub_type_attrs)
      assert_equal 'Validation error', x.message
      assert_equal false, x.success

      x = interactor.update_matres_sub_type(1, matres_sub_type_attrs.merge(sub_type_name: 'Updated value'))
      assert x.success
      assert_equal 'Updated sub type Bag Fruit', x.message
      assert_instance_of MatresSubType, x.instance
    end

    def test_delete_matres_sub_type
      ConfigRepo.any_instance.stubs(:delete_matres_sub_type).returns(true)
      ConfigInteractor.any_instance.stubs(:matres_sub_type).returns(fake_matres_sub_type)

      x = interactor.delete_matres_sub_type(1)
      assert x.success
      assert_equal 'Deleted sub type Bag Fruit', x.message
    end

    def matres_sub_type_attrs
      {
        id: 1,
        material_resource_type_id: 1,
        sub_type_name: 'Bag Fruit',
        short_code: 'BF',
        product_code_separator: '_',
        has_suppliers: false,
        has_marketers: false,
        has_retailers: false,
        product_column_ids: [],
        product_code_ids: []
      }
    end

    def fake_matres_sub_type
      MatresSubType.new(matres_sub_type_attrs)
    end

    def invalid_matres_sub_type_attrs
      matres_sub_type_attrs.merge(sub_type_name: nil)
    end

    def test_validate_material_resource_type_config_code_columns_params
      # PLEASE NOTE: These validation tests are not like the rest. They test a custom DRY Type - ArrayFromString
      # see MatresSubTypeConfigColumnsSchema
      test_attrs = {
        chosen_column_ids: '1,5,8,1,5',
        columncodes_sorted_ids: '1,2,3,4'
      }
      x = interactor.send(:validate_material_resource_type_config_code_columns_params, test_attrs)
      assert_empty x.errors

      # required(:chosen_column_ids, :array).filled { each(:int?) }
      x = interactor.send(:validate_material_resource_type_config_code_columns_params, test_attrs.reject { |k| k == :chosen_column_ids })
      assert_equal(['is missing'], x.errors[:chosen_column_ids])
      x = interactor.send(:validate_material_resource_type_config_code_columns_params, test_attrs.merge(chosen_column_ids: nil))
      assert_equal(['must be filled'], x.errors[:chosen_column_ids])
      x = interactor.send(:validate_material_resource_type_config_code_columns_params, test_attrs.merge(chosen_column_ids: ''))
      assert_equal(['must be filled'], x.errors[:chosen_column_ids])
      x = interactor.send(:validate_material_resource_type_config_code_columns_params, test_attrs.merge(chosen_column_ids: '1,2,3,w,5'))
      assert_equal(['must be an array'], x.errors[:chosen_column_ids])

      # required(:columncodes_sorted_ids, Types::ArrayFromString).filled(:array?) { each(:int?) }
      x = interactor.send(:validate_material_resource_type_config_code_columns_params, test_attrs.reject { |k| k == :columncodes_sorted_ids })
      assert_equal(['is missing'], x.errors[:columncodes_sorted_ids])
      x = interactor.send(:validate_material_resource_type_config_code_columns_params, test_attrs.merge(columncodes_sorted_ids: ''))
      assert_equal(['must be filled'], x.errors[:columncodes_sorted_ids])
      x = interactor.send(:validate_material_resource_type_config_code_columns_params, test_attrs.merge(columncodes_sorted_ids: nil))
      assert_equal(['must be filled'], x.errors[:columncodes_sorted_ids])
      x = interactor.send(:validate_material_resource_type_config_code_columns_params, test_attrs.merge(columncodes_sorted_ids: '1,2,3,w,5'))
      assert_equal(['must be an array'], x.errors[:columncodes_sorted_ids])
    end

    def invalid_matres_config_attrs
      matres_sub_type_attrs.merge(product_code_separator: nil)
    end

    def test_update_matres_config
      ConfigRepo.any_instance.stubs(:update_matres_sub_type).returns(fake_matres_sub_type)

      x = interactor.update_matres_config(1, invalid_matres_config_attrs)
      assert_equal 'Validation error', x.message
      assert_equal false, x.success

      x = interactor.update_matres_config(1, matres_sub_type_attrs)
      assert x.success
      assert_equal 'Updated the config', x.message
    end

    def test_chosen_product_columns
      non_var = [['a', 1], ['a', 2], ['a', 3]]
      ConfigRepo.any_instance.stubs(:product_code_column_subset).returns(non_var)
      res = interactor.chosen_product_columns([1, 2, 3, 4])
      assert_equal [['a', 1], ['a', 2], ['a', 3]], res.instance[:code]
    end

    def test_update_product_code_config
      ConfigRepo.any_instance.stubs(:update_product_code_configuration)
      res = interactor.update_product_code_configuration(1, chosen_column_ids: '1,2,3', columncodes_sorted_ids: '1,2')
      assert res.success
      res = interactor.update_product_code_configuration(1, chosen_column_ids: '', columncodes_sorted_ids: '')
      refute res.success
      assert_match(/Validation/, res.message)
      res = interactor.update_product_code_configuration(1, chosen_column_ids: '1,2,3', columncodes_sorted_ids: '')
      refute res.success
      assert_match(/Validation/, res.message)
    end

    def test_create_matres_master_list_item
      ConfigRepo.any_instance.stubs(:create_matres_master_list_item).returns(id: 1)
      ConfigInteractor.any_instance.stubs(:matres_master_list_item).returns(fake_matres_master_list_item)

      x = interactor.create_matres_master_list_item(1, invalid_matres_master_list_item_attrs)
      assert_equal false, x.success
      assert_equal 'Validation error', x.message

      x = interactor.create_matres_master_list_item(1, matres_master_list_item_attrs)
      assert x.success
      assert_equal 'Created list item BF', x.message
      assert_instance_of MatresMasterListItem, x.instance

      ConfigRepo.any_instance.stubs(:create_matres_master_list_item).raises(Sequel::UniqueConstraintViolation)
      x = interactor.create_matres_master_list_item(1, matres_master_list_item_attrs)
      expected = interactor.validation_failed_response(OpenStruct.new(messages: { short_code: ['This list item already exists'] }))
      assert_equal expected, x
      refute x.success
    end

    def test_update_matres_master_list_item
      ConfigRepo.any_instance.stubs(:update_matres_master_list_item).returns(fake_matres_master_list_item)
      ConfigInteractor.any_instance.stubs(:matres_master_list_item).returns(fake_matres_master_list_item)

      x = interactor.update_matres_master_list_item(1, invalid_matres_master_list_item_attrs)
      assert_equal 'Validation error', x.message
      assert_equal false, x.success

      x = interactor.update_matres_master_list_item(1, matres_master_list_item_attrs.merge(sub_type_name: 'Updated value'))
      assert x.success
      assert_equal 'Updated list item BF', x.message
      assert_instance_of MatresMasterListItem, x.instance
    end

    def matres_master_list_item_attrs
      {
        id: 1,
        material_resource_master_list_id: 1,
        short_code: 'BF',
        long_name: 'Bag Fruit',
        description: 'description',
        active: true
      }
    end

    def fake_matres_master_list_item
      MatresMasterListItem.new(matres_master_list_item_attrs)
    end

    def invalid_matres_master_list_item_attrs
      matres_master_list_item_attrs.merge(short_code: nil)
    end

    def test_matres_master_list_item
      ConfigRepo.any_instance.stubs(:find_matres_master_list_item).returns(fake_matres_master_list_item)
      x = interactor.send(:matres_master_list_item, 1)
      assert_equal 'BF', x.short_code
    end

    def test_validate_matres_master_list_item_params
      test_attrs = matres_master_list_item_attrs
      x = interactor.send(:validate_matres_master_list_item_params, test_attrs)
      assert_empty x.errors

      # optional(:id).filled(:int?)
      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.reject { |k| k == :id })
      assert_empty x. errors

      # optional(:material_resource_master_list_id, :int).filled(:int?)
      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.merge(material_resource_master_list_id: 'string'))
      assert_equal(['must be an integer'], x.errors[:material_resource_master_list_id])

      # optional(:short_code, Types::StrippedString).filled(:str?)
      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.reject { |k| k == :short_code })
      assert_nil x.errors[:short_code]

      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.merge(short_code: nil))
      assert_equal(['must be filled'], x.errors[:short_code])

      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.merge(short_code: 1))
      assert_equal(['must be a string'], x.errors[:short_code])

      # required(:long_name, Types::StrippedString).maybe(:str?)
      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.reject { |k| k == :long_name })
      assert_equal(['is missing'], x.errors[:long_name])

      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.merge(long_name: 1))
      assert_equal(['must be a string'], x.errors[:long_name])

      # required(:description, Types::StrippedString).maybe(:str?)
      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.reject { |k| k == :description })
      assert_equal(['is missing'], x.errors[:description])

      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.merge(description: 1))
      assert_equal(['must be a string'], x.errors[:description])

      # optional(:active, :bool).filled(:bool?)
      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.reject { |k| k == :active })
      assert_nil x.errors[:active]

      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.merge(active: nil))
      assert_equal(['must be filled'], x.errors[:active])

      x = interactor.send(:validate_matres_master_list_item_params, test_attrs.merge(active: 'string'))
      assert_equal(['must be boolean'], x.errors[:active])
    end

    private

    def interactor
      @interactor ||= ConfigInteractor.new(current_user, {}, {}, {})
    end
  end
end
