# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

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
      expected = interactor.validation_failed_response(OpenStruct.new(messages: { type_name: ['must be filled'] }))
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
        domain_name: 'Pack Material'
      }
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
        product_code_separator: '_',
        has_suppliers: false,
        has_marketers: false,
        has_retailer: false,
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

    def test_chosen_product_columns
      non_var = [['a', 1], ['a', 2], ['a', 3]]
      var = [['a', 4]]
      ConfigRepo.any_instance.stubs(:non_variant_columns_subset).returns(non_var)
      ConfigRepo.any_instance.stubs(:variant_columns_subset).returns(var)
      res = interactor.chosen_product_columns([1, 2, 3, 4])
      assert_equal [['a', 1], ['a', 2], ['a', 3]], res.instance[:code]
      assert_equal [['a', 4]], res.instance[:var]
    end

    def test_update_product_code_config
      ConfigRepo.any_instance.stubs(:update_product_code_configuration)
      res = interactor.update_product_code_configuration(1, chosen_column_ids: '1,2,3', columncodes_sorted_ids: '1,2', variantcolumncodes_sorted_ids: '')
      assert res.success
      res = interactor.update_product_code_configuration(1, chosen_column_ids: '', columncodes_sorted_ids: '', variantcolumncodes_sorted_ids: '')
      refute res.success
      assert_match(/Validation/, res.message)
      res = interactor.update_product_code_configuration(1, chosen_column_ids: '1,2,3', columncodes_sorted_ids: '', variantcolumncodes_sorted_ids: '')
      refute res.success
      assert_match(/Validation/, res.message)
    end

    private

    def interactor
      @interactor ||= ConfigInteractor.new(current_user, {}, {}, {})
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
