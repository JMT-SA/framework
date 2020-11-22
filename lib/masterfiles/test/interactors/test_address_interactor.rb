require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestAddressInteractor < Minitest::Test
    def test_party_repo
      x = interactor.send(:repo)
      assert x.is_a?(PartyRepo)
    end

    def test_address
      PartyRepo.any_instance.stubs(:find_address).returns(Address.new(address_attrs))
      x = interactor.send(:address, 1)
      assert x.is_a?(Address)
    end

    def test_validate_address_params
      x = interactor.send(:validate_address_params, address_attrs)
      assert_empty x.errors

      # optional(:id).filled(:int?)
      addr_attrs_without_id = address_attrs.reject { |k, _| k == :id }
      x = interactor.send(:validate_address_params, addr_attrs_without_id)
      assert_empty x.errors

      # optional(:address_type_id).maybe(:int?)
      my_addr = address_attrs
      my_addr[:address_type_id] = 'Some string value'
      x = interactor.send(:validate_address_params, my_addr)
      assert_equal(['must be an integer'], x.errors[:address_type_id])
      refute_empty x.errors.to_h

      my_addr[:address_type_id] = '1'
      x = interactor.send(:validate_address_params, my_addr)
      assert_empty x.errors

      # required(:address_line_1).filled(:str?)
      addr_attrs_without_address_line1 = address_attrs.reject { |k, _| k == :address_line_1 }
      x = interactor.send(:validate_address_params, addr_attrs_without_address_line1)
      assert_equal(['is missing'], x.errors[:address_line_1])
      refute_empty x.errors

      addr_attrs_without_address_line1[:address_line_1] = 1
      x = interactor.send(:validate_address_params, addr_attrs_without_address_line1)
      refute_empty x.errors
      expected = { address_line_1: ['must be a string'] }
      assert_equal(expected, x.errors.to_h)

      # required(:address_line_2).maybe(:str?)
      addr_attrs_without_address_line2 = address_attrs.reject { |k, _| k == :address_line_2 }
      x = interactor.send(:validate_address_params, addr_attrs_without_address_line2)
      assert_equal(['is missing'], x.errors[:address_line_2])
      refute_empty x.errors
      addr_attrs_without_address_line2[:address_line_2] = 'name'
      x = interactor.send(:validate_address_params, addr_attrs_without_address_line2)
      assert_empty x.errors
      addr_attrs_without_address_line2[:address_line_2] = 1
      x = interactor.send(:validate_address_params, addr_attrs_without_address_line2)
      expected = { address_line_2: ['must be a string'] }
      assert_equal(x.errors.to_h, expected)

      # required(:address_line_3).maybe(:str?)
      addr_attrs_without_address_line3 = address_attrs.reject { |k, _| k == :address_line_3 }
      x = interactor.send(:validate_address_params, addr_attrs_without_address_line3)
      assert_equal(['is missing'], x.errors[:address_line_3])
      refute_empty x.errors
      addr_attrs_without_address_line3[:address_line_3] = 'name'
      x = interactor.send(:validate_address_params, addr_attrs_without_address_line3)
      assert_empty x.errors
      addr_attrs_without_address_line3[:address_line_3] = 1
      x = interactor.send(:validate_address_params, addr_attrs_without_address_line3)
      expected = { address_line_3: ['must be a string'] }
      assert_equal(x.errors.to_h, expected)

      # required(:city).maybe(:str?)
      addr_attrs_without_city = address_attrs.reject { |k, _| k == :city }
      x = interactor.send(:validate_address_params, addr_attrs_without_city)
      assert_equal(['is missing'], x.errors[:city])
      refute_empty x.errors
      addr_attrs_without_city[:city] = 'name'
      x = interactor.send(:validate_address_params, addr_attrs_without_city)
      assert_empty x.errors
      addr_attrs_without_city[:city] = 1
      x = interactor.send(:validate_address_params, addr_attrs_without_city)
      expected = { city: ['must be a string'] }
      assert_equal(expected, x.errors.to_h)

      # required(:postal_code).maybe(:str?)
      addr_attrs_without_postal_code = address_attrs.reject { |k, _| k == :postal_code }
      x = interactor.send(:validate_address_params, addr_attrs_without_postal_code)
      assert_equal(['is missing'], x.errors[:postal_code])
      refute_empty x.errors
      addr_attrs_without_postal_code[:postal_code] = '1'
      x = interactor.send(:validate_address_params, addr_attrs_without_postal_code)
      assert_empty x.errors
      addr_attrs_without_postal_code[:postal_code] = 1
      x = interactor.send(:validate_address_params, addr_attrs_without_postal_code)
      expected = { postal_code: ['must be a string'] }
      assert_equal(expected, x.errors.to_h)

      # required(:country).maybe(:str?)
      addr_attrs_without_country = address_attrs.reject { |k, _| k == :country }
      x = interactor.send(:validate_address_params, addr_attrs_without_country)
      assert_equal(['is missing'], x.errors[:country])
      refute_empty x.errors
      addr_attrs_without_country[:country] = 'name'
      x = interactor.send(:validate_address_params, addr_attrs_without_country)
      assert_empty x.errors
      addr_attrs_without_country[:country] = 1
      x = interactor.send(:validate_address_params, addr_attrs_without_country)
      expected = { country: ['must be a string'] }
      assert_equal(expected, x.errors.to_h)
    end

    def test_create_address
      PartyRepo.any_instance.stubs(:create_address).returns(id: 1)
      PartyRepo.any_instance.stubs(:find_address).returns(fake_address)

      x = interactor.create_address(invalid_address)
      assert_equal(false, x.success)
      assert_equal('Validation error', x.message)

      x = interactor.create_address(address_for_create)
      assert x.success
      assert_instance_of(Address, x.instance)
      assert_equal('Created address Address line 1', x.message)
    end

    def test_update_address
      # Fails on invalid update
      x = interactor.update_address(1, invalid_address)
      assert_equal(false, x.success)
      # Gives validation failed response on fail
      response_attrs = invalid_address.reject { |k| k == :active }
      expected = interactor.validation_failed_response(OpenStruct.new(messages: { address_line_1: ['must be a string'] }, **response_attrs))
      assert_equal(expected, x)

      # Updates successfully
      PartyRepo.any_instance.stubs(:update_address).returns(true)
      AddressInteractor.any_instance.stubs(:address).returns(fake_address)
      update_attrs = address_attrs.merge(address_line_1: 'Changed Address Line 1')
      x = interactor.update_address(1, update_attrs)
      expected = interactor.success_response('Updated address Address line 1', fake_address)
      assert_equal(expected, x)
      assert x.success
    end

    def test_delete_address
      PartyRepo.any_instance.stubs(:delete_address).returns(true)
      AddressInteractor.any_instance.stubs(:address).returns(fake_address)
      x = interactor.delete_address(1)
      expected = interactor.success_response('Deleted address Address line 1')
      assert_equal(expected, x)
    end

    private

    def interactor
      @interactor ||= AddressInteractor.new(current_user, {}, {}, {})
    end

    def address_attrs
      {
        id: 1,
        address_type_id: 1,
        address_line_1: 'Address line 1',
        address_line_2: 'Address line 2',
        address_line_3: 'Address line 3',
        city: 'City',
        postal_code: '7894',
        country: 'Country',
        active: true,
        address_type: 'Postal Address'
      }
    end

    def address_for_create
      keys = %i[address_type_id address_line_1 address_line_2 address_line_3 city postal_code country active]
      address_attrs.select { |key, _| keys.include?(key) }
    end

    def invalid_address
      keys = %i[address_type_id address_line_1 address_line_2 address_line_3 city postal_code country active]
      addr_attrs = address_attrs.select { |key, _| keys.include?(key) }
      addr_attrs[:address_line_1] = 789_456
      addr_attrs
    end

    def fake_address
      Address.new(address_attrs)
    end
  end
end
