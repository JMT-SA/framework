# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class TestCustomerInteractor < Minitest::Test
    def test_create_customer
      x = interactor.create_customer(party_id: 1)
      refute x.success

      PartyRepo.any_instance.stubs(:find_full_customer).returns(fake_customer)

      exp = interactor.success_response('Created customer Customer Name', fake_customer)
      PartyRepo.any_instance.stubs(:create_customer).returns(OpenStruct.new(success: true))
      x = interactor.create_customer(customer_attrs)
      assert_equal exp, x

      error_message = 'error message'
      exp = interactor.validation_failed_response(OpenStruct.new(messages: error_message))
      PartyRepo.any_instance.stubs(:create_customer).returns(error: error_message)
      x = interactor.create_customer(customer_attrs)
      assert_equal exp, x

      PartyRepo.any_instance.stubs(:create_customer).raises(Sequel::UniqueConstraintViolation)
      x = interactor.create_customer(customer_attrs)
      refute x.success
      error_message = { erp_customer_number: ['This customer already exists'] }
      exp = interactor.validation_failed_response(OpenStruct.new(messages: error_message))
      assert_equal exp, x
    end

    def test_update_customer
      x = interactor.create_customer(party_id: 1)
      refute x.success

      PartyRepo.any_instance.stubs(:find_full_customer).returns(fake_customer)

      exp = interactor.success_response('Updated customer Customer Name', fake_customer)
      PartyRepo.any_instance.stubs(:update_customer).returns(OpenStruct.new(success: true))
      x = interactor.update_customer(1, customer_attrs)
      assert_equal exp, x

      error_message = 'error message'
      exp = interactor.validation_failed_response(OpenStruct.new(messages: error_message))
      PartyRepo.any_instance.stubs(:update_customer).returns(error: error_message)
      x = interactor.update_customer(1, customer_attrs)
      assert_equal exp, x
    end

    def test_delete_customer
      PartyRepo.any_instance.stubs(:find_full_customer).returns(OpenStruct.new(party_name: 'Customer Name'))
      PartyRepo.any_instance.stubs(:delete_customer).returns(true)

      x = interactor.delete_customer(1)
      assert_equal 'Deleted customer Customer Name', x[:message]
    end

    def test_validate_new_customer_params
      attrs = customer_attrs

      x = interactor.send(:validate_new_customer_params, attrs)
      assert_empty x.errors

      # optional(:id).filled(:int?)
      attrs_without_id = attrs.reject { |k, _| k == :id }
      x = interactor.send(:validate_new_customer_params, attrs_without_id)
      assert_empty x.errors

      # required(:party_id).filled(:int?)
      attrs_without_party_id = attrs.reject { |k, _| k == :party_id }
      x = interactor.send(:validate_new_customer_params, attrs_without_party_id)
      assert_equal(['is missing'], x.errors[:party_id])
      refute_empty x.errors

      # required(:customer_type_ids).each(:int?)
      attrs_without_customer_type_ids = attrs.reject { |k, _| k == :customer_type_ids }
      x = interactor.send(:validate_new_customer_params, attrs_without_customer_type_ids)
      assert_equal(['is missing'], x.errors[:customer_type_ids])
      refute_empty x.errors
      attrs_without_customer_type_ids[:customer_type_ids] = ['String one', 'String two', 'String three']
      x = interactor.send(:validate_new_customer_params, attrs_without_customer_type_ids)
      refute_empty x.errors
      expected = { customer_type_ids: { 0 => ['must be an integer'], 1 => ['must be an integer'], 2 => ['must be an integer'] } }
      assert_equal(expected, x.errors)

      # required(:erp_customer_number).maybe(:str?)
      attrs_without_erp_customer_number = attrs.reject { |k, _| k == :erp_customer_number }
      x = interactor.send(:validate_new_customer_params, attrs_without_erp_customer_number)
      assert_equal(['is missing'], x.errors[:erp_customer_number])
      refute_empty x.errors
      attrs_without_erp_customer_number[:erp_customer_number] = 'name'
      x = interactor.send(:validate_new_customer_params, attrs_without_erp_customer_number)
      assert_empty x.errors
      attrs_without_erp_customer_number[:erp_customer_number] = 1
      x = interactor.send(:validate_new_customer_params, attrs_without_erp_customer_number)
      expected = { erp_customer_number: ['must be a string'] }
      assert_equal(x.errors, expected)
    end

    def test_validate_edit_customer_params
      attrs = customer_attrs

      x = interactor.send(:validate_edit_customer_params, attrs)
      assert_empty x.errors

      # optional(:id).filled(:int?)
      attrs_without_id = attrs.reject { |k, _| k == :id }
      x = interactor.send(:validate_edit_customer_params, attrs_without_id)
      assert_empty x.errors

      # required(:customer_type_ids).each(:int?)
      attrs_without_customer_type_ids = attrs.reject { |k, _| k == :customer_type_ids }
      x = interactor.send(:validate_edit_customer_params, attrs_without_customer_type_ids)
      assert_equal(['is missing'], x.errors[:customer_type_ids])
      refute_empty x.errors
      attrs_without_customer_type_ids[:customer_type_ids] = ['String one', 'String two', 'String three']
      x = interactor.send(:validate_edit_customer_params, attrs_without_customer_type_ids)
      refute_empty x.errors
      expected = { customer_type_ids: { 0 => ['must be an integer'], 1 => ['must be an integer'], 2 => ['must be an integer'] } }
      assert_equal(expected, x.errors)

      # required(:erp_customer_number).maybe(:str?)
      attrs_without_erp_customer_number = attrs.reject { |k, _| k == :erp_customer_number }
      x = interactor.send(:validate_edit_customer_params, attrs_without_erp_customer_number)
      assert_equal(['is missing'], x.errors[:erp_customer_number])
      refute_empty x.errors
      attrs_without_erp_customer_number[:erp_customer_number] = 'name'
      x = interactor.send(:validate_edit_customer_params, attrs_without_erp_customer_number)
      assert_empty x.errors
      attrs_without_erp_customer_number[:erp_customer_number] = 1
      x = interactor.send(:validate_edit_customer_params, attrs_without_erp_customer_number)
      expected = { erp_customer_number: ['must be a string'] }
      assert_equal(x.errors, expected)
    end

    def customer_attrs
      {
        id: 1,
        party_id: 1,
        party_role_id: 1,
        erp_customer_number: '123456',
        customer_type_ids: [4, 5, 6]
      }
    end

    def full_customer_attrs
      {
        id: 1,
        party_id: 1,
        party_role_id: 1,
        erp_customer_number: '123456',
        customer_type_ids: [4, 5, 6],
        customer_types: ['Internal', 'Type 1', 'Type 2'],
        party_name: 'Customer Name'
      }
    end

    def fake_customer
      OpenStruct.new(full_customer_attrs)
    end

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(MasterfilesApp::PartyRepo)
    end

    def test_customer
      expected = 'This is a full customer returned from the repo'
      PartyRepo.any_instance.stubs(:find_full_customer).returns(expected)
      actual = interactor.send(:customer, 1)
      assert_equal expected, actual
    end

    private

    def interactor
      @interactor ||= CustomerInteractor.new(current_user, {}, {}, {})
    end
  end
end
# rubocop:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
