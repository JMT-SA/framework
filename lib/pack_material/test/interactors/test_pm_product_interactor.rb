# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop#:disable Metrics/ClassLength
# rubocop#:disable Metrics/AbcSize

module PackMaterialApp
  class TestPmProductInteractor < MiniTestInteractors
    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(PackMaterialApp::PmProductRepo)
    end

    def test_pm_product
      PmProductRepo.any_instance.stubs(:find_pm_product).returns(fake_pm_product)
      x = interactor.send(:pm_product, 1)
      assert x.is_a?(PmProduct)
    end

    def test_pm_product_variant
      PmProductRepo.any_instance.stubs(:find_pm_product_variant).returns(fake_pm_product_variant)
      x = interactor.send(:pm_product_variant, 1)
      assert x.is_a?(PmProductVariant)
    end

    def test_create_pm_product
      PmProductInteractor.any_instance.stubs(:pm_product_create).returns(OpenStruct.new(success: true))

      x = interactor.create_pm_product(invalid_pm_product_attrs)
      assert_equal false, x.success
      assert_equal 'Validation error', x.message

      x = interactor.create_pm_product(pm_product_attrs.reject { |k| k == :id })
      assert x.success
    end

    def test_clone_pm_product
      PmProductInteractor.any_instance.stubs(:pm_product_create).returns(OpenStruct.new(success: true))

      x = interactor.clone_pm_product(invalid_pm_product_attrs)
      assert_equal false, x.success
      assert_equal 'Validation error', x.message

      x = interactor.clone_pm_product(pm_product_attrs.reject { |k| k == :material_resource_sub_type_id })
      assert_equal false, x.success
      assert_equal 'Validation error', x.message

      x = interactor.clone_pm_product(pm_product_attrs.reject { |k| k == :id })
      assert x.success
    end

    def test_pm_product_create
      PmProductRepo.any_instance.stubs(:create_pm_product).returns(nil)
      PmProductRepo.any_instance.stubs(:find_pm_product).returns(fake_pm_product)

      x = interactor.send(:pm_product_create, {})
      assert x.success
      assert_equal('Created product', x.message)
      assert_instance_of(PmProduct, x.instance)

      PmProductRepo.any_instance.stubs(:create_pm_product).raises(Sequel::UniqueConstraintViolation)
      x = interactor.send(:pm_product_create, {})
      refute x.success
      assert_equal('Validation error', x.message)
      assert_equal(['This product already exists'], x.errors[:product_number])
    end

    def test_update_pm_product
      # Fails on invalid update
      x = interactor.update_pm_product(1, invalid_pm_product_attrs)
      assert_equal(false, x.success)
      # Gives validation failed response on fail
      assert_equal 'Validation error', x.message
      assert_equal ['must be filled'], x.errors[:material_resource_sub_type_id]

      # Updates successfully
      PmProductRepo.any_instance.stubs(:update_pm_product).returns(OpenStruct.new(success: true))
      PmProductInteractor.any_instance.stubs(:pm_product).returns(fake_pm_product)
      update_attrs = pm_product_attrs.merge(unit: 'Changed Unit')
      x = interactor.update_pm_product(1, update_attrs)
      expected = interactor.success_response('Updated product product_code', fake_pm_product)
      assert_equal(expected, x)
      assert x.success

      PmProductRepo.any_instance.stubs(:update_pm_product).returns(OpenStruct.new(success: false, message: 'Test message'))
      update_attrs = pm_product_attrs.merge(unit: 'Changed Unit')
      x = interactor.update_pm_product(1, update_attrs)
      refute x.success
      assert_equal('Test message', x.message)
    end

    def test_delete_pm_product
      PmProductRepo.any_instance.stubs(:delete_pm_product).returns(OpenStruct.new(success: true))
      PmProductInteractor.any_instance.stubs(:pm_product).returns(fake_pm_product)
      x = interactor.delete_pm_product(1)
      expected = interactor.success_response('Deleted product product_code')
      assert_equal(expected, x)
      assert x.success

      PmProductRepo.any_instance.stubs(:delete_pm_product).returns(OpenStruct.new(success: false, message: 'Test message'))
      x = interactor.delete_pm_product(1)
      assert_equal('Test message', x.message)
      refute x.success
    end

    # def test_delete_matres_sub_type
    #   ConfigRepo.any_instance.stubs(:delete_matres_sub_type).returns(OpenStruct.new(success: true))
    #   ConfigInteractor.any_instance.stubs(:matres_sub_type).returns(fake_matres_sub_type)
    #
    #   x = interactor.delete_matres_sub_type(1)
    #   assert x.success
    #   assert_equal 'Deleted sub type Bag Fruit', x.message
    #
    #   ConfigRepo.any_instance.stubs(:delete_matres_sub_type).returns(OpenStruct.new(success: false, message: 'Test message'))
    #
    #   x = interactor.delete_matres_sub_type(1)
    #   refute x.success
    #   assert_equal 'Test message', x.message
    # end
    #

    def test_create_pm_product_variant
      x = interactor.create_pm_product_variant(nil, {})
      refute x.success
      assert_equal ['is missing'], x.errors[:pack_material_product_id]

      x = interactor.create_pm_product_variant('asdf', invalid_pm_product_variant_attrs)
      assert_equal false, x.success
      assert_equal 'Validation error', x.message

      PmProductInteractor.any_instance.stubs(:pm_product_variant_create).returns(true)
      x = interactor.create_pm_product_variant(1, pm_product_variant_attrs)
      assert x
    end

    def test_clone_pm_product_variant
      x = interactor.clone_pm_product_variant(nil, {})
      refute x.success
      assert_equal ['is missing'], x.errors[:pack_material_product_id]

      x = interactor.clone_pm_product_variant('asdf', invalid_pm_product_variant_attrs)
      assert_equal false, x.success
      assert_equal 'Validation error', x.message

      PmProductInteractor.any_instance.stubs(:pm_product_variant_create).returns(true)
      x = interactor.clone_pm_product_variant(1, pm_product_variant_attrs)
      assert x
    end

    def test_pm_product_variant_create
      PmProductRepo.any_instance.stubs(:create_pm_product_variant).returns(success_response('Created product variant', fake_pm_product))
      PmProductRepo.any_instance.stubs(:find_pm_product_variant).returns(fake_pm_product)

      x = interactor.send(:pm_product_variant_create, {})
      assert x.success
      assert_equal('Created product variant', x.message)
      assert_instance_of(PmProduct, x.instance)

      PmProductRepo.any_instance.stubs(:create_pm_product_variant).raises(Sequel::UniqueConstraintViolation)
      x = interactor.send(:pm_product_variant_create, {})
      refute x.success
      assert_equal('Validation error', x.message)
      assert_equal(['This product variant already exists'], x.errors[:base])
    end

    def test_update_pm_product_variant
      # Fails on invalid update
      x = interactor.update_pm_product_variant(1, invalid_pm_product_variant_attrs)
      assert_equal(false, x.success)
      # Gives validation failed response on fail
      assert_equal 'Validation error', x.message
      assert_equal ['must be filled'], x.errors[:pack_material_product_id]

      # Updates successfully
      PmProductRepo.any_instance.stubs(:update_pm_product_variant).returns(true)
      PmProductInteractor.any_instance.stubs(:pm_product_variant).returns(fake_pm_product_variant)
      update_attrs = pm_product_variant_attrs.merge(unit: 'Changed Unit')
      x = interactor.update_pm_product_variant(1, update_attrs)
      expected = interactor.success_response('Updated pack material product variant 11223333444', fake_pm_product_variant)
      assert_equal(expected, x)
      assert x.success
    end

    def test_delete_pm_product_variant
      PmProductRepo.any_instance.stubs(:delete_pm_product_variant).returns(true)
      PmProductInteractor.any_instance.stubs(:pm_product_variant).returns(fake_pm_product_variant)
      x = interactor.delete_pm_product_variant(1)
      expected = interactor.success_response('Deleted pack material product variant 11223333444')
      assert_equal(expected, x)
    end

    # VALIDATIONS
    def test_validate_pm_product_params
      # PmProductSchema
      test_attrs = pm_product_attrs
      # optional(:material_resource_sub_type_id).filled(:int?)
      x = interactor.send(:validate_pm_product_params, test_attrs.reject { |k| k == :material_resource_sub_type_id })
      assert_empty x. errors

      x = interactor.send(:validate_pm_product_params, test_attrs.merge(material_resource_sub_type_id: 'name'))
      assert_equal(['must be an integer'], x.errors[:material_resource_sub_type_id])

      # optional(:commodity_id).filled(:int?)
      x = interactor.send(:validate_pm_product_params, test_attrs.reject { |k| k == :commodity_id })
      assert_empty x. errors

      x = interactor.send(:validate_pm_product_params, test_attrs.merge(commodity_id: 'name'))
      assert_equal(['must be an integer'], x.errors[:commodity_id])

      # optional(:marketing_variety_id).filled(:int?)
      x = interactor.send(:validate_pm_product_params, test_attrs.reject { |k| k == :marketing_variety_id })
      assert_empty x. errors

      x = interactor.send(:validate_pm_product_params, test_attrs.merge(marketing_variety_id: 'name'))
      assert_equal(['must be an integer'], x.errors[:marketing_variety_id])

      %i[
        unit
        style
        alternate
        shape
        reference_size
        reference_dimension
        reference_quantity
        brand_1
        brand_2
        colour
        material
        assembly
        reference_mass
        reference_number
        market
        marking
        model
        pm_class
        grade
        language
        other
      ].each do |key|
        x = interactor.send(:validate_pm_product_params, test_attrs.reject { |k| k == key })
        assert_empty x.errors

        x = interactor.send(:validate_pm_product_params, test_attrs.merge(key => nil))
        assert_equal(['must be filled'], x.errors[key])

        x = interactor.send(:validate_pm_product_params, test_attrs.merge(key => 1))
        assert_equal(['must be a string'], x.errors[key])
      end
    end

    def test_validate_clone_pm_product_params
      # ClonePmProductSchema
      test_attrs = pm_product_attrs
      # required(:material_resource_sub_type_id, :integer).filled(:int?)
      x = interactor.send(:validate_clone_pm_product_params, test_attrs.reject { |k| k == :material_resource_sub_type_id })
      assert_equal(['is missing'], x.errors[:material_resource_sub_type_id])

      x = interactor.send(:validate_clone_pm_product_params, test_attrs.merge(material_resource_sub_type_id: nil))
      assert_equal(['must be filled'], x.errors[:material_resource_sub_type_id])

      x = interactor.send(:validate_clone_pm_product_params, test_attrs.merge(material_resource_sub_type_id: 'name'))
      assert_equal(['must be an integer'], x.errors[:material_resource_sub_type_id])

      # optional(:commodity_id, :integer).filled(:int?)
      x = interactor.send(:validate_clone_pm_product_params, test_attrs.reject { |k| k == :commodity_id })
      assert_empty x. errors

      x = interactor.send(:validate_clone_pm_product_params, test_attrs.merge(commodity_id: 'name'))
      assert_equal(['must be an integer'], x.errors[:commodity_id])

      # optional(:marketing_variety_id, :integer).filled(:int?)
      x = interactor.send(:validate_clone_pm_product_params, test_attrs.reject { |k| k == :marketing_variety_id })
      assert_empty x. errors

      x = interactor.send(:validate_clone_pm_product_params, test_attrs.merge(marketing_variety_id: 'name'))
      assert_equal(['must be an integer'], x.errors[:marketing_variety_id])

      %i[
        unit
        style
        alternate
        shape
        reference_size
        reference_dimension
        reference_quantity
        brand_1
        brand_2
        colour
        material
        assembly
        reference_mass
        reference_number
        market
        marking
        model
        pm_class
        grade
        language
        other
      ].each do |key|
        x = interactor.send(:validate_clone_pm_product_params, test_attrs.reject { |k| k == key })
        assert_empty x.errors

        x = interactor.send(:validate_clone_pm_product_params, test_attrs.merge(key => nil))
        assert_equal(['must be filled'], x.errors[key])

        x = interactor.send(:validate_clone_pm_product_params, test_attrs.merge(key => 1))
        assert_equal(['must be a string'], x.errors[key])
      end
    end

    def test_validate_completed_pm_product_params
      # CompletedPmProductSchema
      test_attrs = pm_product_attrs
      # required(:product_number, :integer).filled(:int?)
      x = interactor.send(:validate_completed_pm_product_params, test_attrs.reject { |k| k == :product_number })
      assert_equal(['is missing'], x.errors[:product_number])

      x = interactor.send(:validate_completed_pm_product_params, test_attrs.merge(product_number: nil))
      assert_equal(['must be filled'], x.errors[:product_number])

      x = interactor.send(:validate_completed_pm_product_params, test_attrs.merge(product_number: 'name'))
      assert_equal(['must be an integer'], x.errors[:product_number])

      # required(:product_code, Types::StrippedString).filled(:str?)
      x = interactor.send(:validate_completed_pm_product_params, test_attrs.reject { |k| k == :product_code })
      assert_equal(['is missing'], x.errors[:product_code])

      x = interactor.send(:validate_completed_pm_product_params, test_attrs.merge(product_code: nil))
      assert_equal(['must be filled'], x.errors[:product_code])

      x = interactor.send(:validate_completed_pm_product_params, test_attrs.merge(product_code: 1))
      assert_equal(['must be a string'], x.errors[:product_code])
    end

    def test_validate_pm_product_variant_params
      # PmProductVariantSchema
      test_attrs = pm_product_variant_attrs
      # optional(:id, :integer).filled(:int?)
      x = interactor.send(:validate_pm_product_variant_params, test_attrs.reject { |k| k == :id })
      assert_empty x. errors

      x = interactor.send(:validate_pm_product_variant_params, test_attrs.merge(id: 'name'))
      assert_equal(['must be an integer'], x.errors[:id])

      # optional(:pack_material_product_id, :integer).filled(:int?)
      x = interactor.send(:validate_pm_product_variant_params, test_attrs.reject { |k| k == :pack_material_product_id })
      assert_empty x.errors

      x = interactor.send(:validate_pm_product_variant_params, test_attrs.merge(pack_material_product_id: 'name'))
      assert_equal(['must be an integer'], x.errors[:pack_material_product_id])

      # optional(:product_variant_number, :integer).filled(:int?)
      x = interactor.send(:validate_pm_product_variant_params, test_attrs.reject { |k| k == :product_variant_number })
      assert_empty x.errors

      x = interactor.send(:validate_pm_product_variant_params, test_attrs.merge(product_variant_number: 'name'))
      assert_equal(['must be an integer'], x.errors[:product_variant_number])

      %i[
        unit
        style
        alternate
        shape
        reference_size
        reference_dimension
        reference_quantity
        brand_1
        brand_2
        colour
        material
        assembly
        reference_mass
        reference_number
        market
        marking
        model
        pm_class
        grade
        language
        other
      ].each do |key|
        x = interactor.send(:validate_pm_product_variant_params, test_attrs.reject { |k| k == key })
        assert_empty x.errors

        x = interactor.send(:validate_pm_product_variant_params, test_attrs.merge(key => 1))
        assert_equal(['must be a string'], x.errors[key])
      end
    end

    def test_validate_clone_pm_product_variant_params
      # ClonePmProductVariantSchema
      test_attrs = pm_product_variant_attrs
      # required(:pack_material_product_id, :integer).filled(:int?)
      x = interactor.send(:validate_clone_pm_product_variant_params, test_attrs.reject { |k| k == :pack_material_product_id })
      assert_equal(['is missing'], x.errors[:pack_material_product_id])

      x = interactor.send(:validate_clone_pm_product_variant_params, test_attrs.merge(pack_material_product_id: nil))
      assert_equal(['must be filled'], x.errors[:pack_material_product_id])

      x = interactor.send(:validate_clone_pm_product_variant_params, test_attrs.merge(pack_material_product_id: 'name'))
      assert_equal(['must be an integer'], x.errors[:pack_material_product_id])

      %i[
        unit
        style
        alternate
        shape
        reference_size
        reference_dimension
        reference_quantity
        brand_1
        brand_2
        colour
        material
        assembly
        reference_mass
        reference_number
        market
        marking
        model
        pm_class
        grade
        language
        other
      ].each do |key|
        x = interactor.send(:validate_clone_pm_product_variant_params, test_attrs.reject { |k| k == key })
        assert_empty x.errors
        #
        # x = interactor.send(:validate_clone_pm_product_variant_params, test_attrs.merge(key => nil))
        # assert_equal(['must be filled'], x.errors[key])

        x = interactor.send(:validate_clone_pm_product_variant_params, test_attrs.merge(key => 1))
        assert_equal(['must be a string'], x.errors[key])
      end
    end

    def test_validate_completed_pm_product_variant_params
      # CompletedPmProductVariantSchema
      test_attrs = pm_product_variant_attrs
      # required(:product_variant_number, Types::StrippedString).filled(:str?)
      x = interactor.send(:validate_completed_pm_product_variant_params, test_attrs.reject { |k| k == :product_variant_number })
      assert_equal(['is missing'], x.errors[:product_variant_number])

      x = interactor.send(:validate_completed_pm_product_variant_params, test_attrs.merge(product_variant_number: nil))
      assert_equal(['must be filled'], x.errors[:product_variant_number])

      x = interactor.send(:validate_completed_pm_product_variant_params, test_attrs.merge(product_variant_number: 'name'))
      assert_equal(['must be an integer'], x.errors[:product_variant_number])
    end

    private

    def interactor
      @interactor ||= PmProductInteractor.new(current_user, {}, {}, {})
    end

    def pm_product_attrs
      {
        id: 1,
        active: true,
        material_resource_sub_type_id: 1,
        alternate: 'alternate',
        assembly: 'assembly',
        brand_1: 'brand_1',
        brand_2: 'brand_2',
        colour: 'colour',
        commodity_id: 1,
        grade: 'grade',
        language: 'language',
        market: 'market',
        marking: 'marking',
        material: 'material',
        model: 'model',
        other: 'other',
        pm_class: 'pm_class',
        product_code: 'product_code',
        product_number: 11_223_333_444,
        reference_dimension: 'reference_dimension',
        reference_mass: 'reference_mass',
        reference_number: 'reference_number',
        reference_quantity: 'reference_quantity',
        reference_size: 'reference_size',
        shape: 'shape',
        style: 'style',
        unit: 'unit',
        marketing_variety_id: 1
      }
    end

    def fake_pm_product
      PmProduct.new(pm_product_attrs)
    end

    def invalid_pm_product_attrs
      pm_product_attrs.merge(material_resource_sub_type_id: nil)
    end

    def pm_product_variant_attrs
      {
        id: 1,
        active: true,
        pack_material_product_id: 1,
        alternate: 'alternate',
        assembly: 'assembly',
        brand_1: 'brand_1',
        brand_2: 'brand_2',
        colour: 'colour',
        commodity_id: 1,
        grade: 'grade',
        language: 'language',
        market: 'market',
        marking: 'marking',
        material: 'material',
        model: 'model',
        other: 'other',
        pm_class: 'pm_class',
        product_code: 'product_code',
        product_variant_number: 11_223_333_444,
        reference_dimension: 'reference_dimension',
        reference_mass: 'reference_mass',
        reference_number: 'reference_number',
        reference_quantity: 'reference_quantity',
        reference_size: 'reference_size',
        shape: 'shape',
        style: 'style',
        unit: 'unit',
        marketing_variety_id: 1
      }
    end

    def fake_pm_product_variant
      PmProductVariant.new(pm_product_variant_attrs)
    end

    def invalid_pm_product_variant_attrs
      pm_product_variant_attrs.merge(pack_material_product_id: nil)
    end
  end
end
# rubocop#:enable Metrics/ClassLength
# rubocop#:enable Metrics/AbcSize
