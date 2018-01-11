require File.join(File.expand_path('../../../../../test', __FILE__), 'test_helper')
require File.join(File.expand_path('../../fake_repositories/', __FILE__), 'fake_party_repo')

class TestOrganizationInteractor < Minitest::Test
  def test_party_repo
    x = interactor.send(:party_repo)
    assert x.is_a?(PartyRepo)
  end

  def test_organization
    PartyRepo.any_instance.stubs(:find_organization).returns(Organization.new(organization_attrs))
    x = interactor.send(:organization)
    assert x.is_a?(Organization)
  end

  def test_validate_organization_params
    x = interactor.send(:validate_organization_params, organization_attrs)
    assert_empty x.errors

    # optional(:id).filled(:int?)
    org_attrs_without_id = organization_attrs.reject { |k, _| k == :id }
    x = interactor.send(:validate_organization_params, org_attrs_without_id)
    assert_empty x.errors

    # optional(:parent_id).maybe(:int?)
    my_org = organization_attrs
    my_org[:parent_id] = 'Some string value'
    x = interactor.send(:validate_organization_params, my_org)
    assert_equal(['must be an integer'], x.errors[:parent_id])
    refute_empty x.errors

    my_org[:parent_id] = '1'
    x = interactor.send(:validate_organization_params, my_org)
    assert_empty x.errors

    # required(:short_description).filled(:str?)
    org_attrs_without_short_description = organization_attrs.reject { |k, _| k == :short_description }
    x = interactor.send(:validate_organization_params, org_attrs_without_short_description)
    assert_equal(['is missing'], x.errors[:short_description])
    refute_empty x.errors

    org_attrs_without_short_description[:short_description] = 1
    x = interactor.send(:validate_organization_params, org_attrs_without_short_description)
    refute_empty x.errors
    expected = {short_description: ['must be a string']}
    assert_equal(expected, x.errors)

    # required(:medium_description).maybe(:str?)
    org_attrs_without_medium_description = organization_attrs.reject { |k, _| k == :medium_description }
    x = interactor.send(:validate_organization_params, org_attrs_without_medium_description)
    assert_equal(['is missing'], x.errors[:medium_description])
    refute_empty x.errors
    org_attrs_without_medium_description[:medium_description] = 'name'
    x = interactor.send(:validate_organization_params, org_attrs_without_medium_description)
    assert_empty x.errors
    org_attrs_without_medium_description[:medium_description] = 1
    x = interactor.send(:validate_organization_params, org_attrs_without_medium_description)
    expected = {medium_description: ['must be a string']}
    assert_equal(x.errors, expected)

    # required(:long_description).maybe(:str?)
    org_attrs_without_long_description = organization_attrs.reject { |k, _| k == :long_description }
    x = interactor.send(:validate_organization_params, org_attrs_without_long_description)
    assert_equal(['is missing'], x.errors[:long_description])
    refute_empty x.errors
    org_attrs_without_long_description[:long_description] = 'name'
    x = interactor.send(:validate_organization_params, org_attrs_without_long_description)
    assert_empty x.errors
    org_attrs_without_long_description[:long_description] = 1
    x = interactor.send(:validate_organization_params, org_attrs_without_long_description)
    expected = {long_description: ['must be a string']}
    assert_equal(expected, x.errors)

    # required(:vat_number).maybe(:str?)
    org_attrs_without_vat_number = organization_attrs.reject { |k, _| k == :vat_number }
    x = interactor.send(:validate_organization_params, org_attrs_without_vat_number)
    assert_equal(['is missing'], x.errors[:vat_number])
    refute_empty x.errors
    org_attrs_without_vat_number[:vat_number] = '1'
    x = interactor.send(:validate_organization_params, org_attrs_without_vat_number)
    assert_empty x.errors
    org_attrs_without_vat_number[:vat_number] = 1
    x = interactor.send(:validate_organization_params, org_attrs_without_vat_number)
    expected = {vat_number: ['must be a string']}
    assert_equal(expected, x.errors)


    # required(:role_ids).each(:int?)
    org_attrs_without_role_ids = organization_attrs.reject { |k, _| k == :role_ids }
    x = interactor.send(:validate_organization_params, org_attrs_without_role_ids)
    assert_equal(['is missing'], x.errors[:role_ids])
    refute_empty x.errors
    org_attrs_without_role_ids[:role_ids] = ['String one', 'String two', 'String three']
    x = interactor.send(:validate_organization_params, org_attrs_without_role_ids)
    refute_empty x.errors
    expected = { role_ids: { 0 => ['must be an integer'], 1 => ['must be an integer'], 2 => ['must be an integer'] } }
    assert_equal(expected, x.errors)

    # assert_equal(['must be a string'], x.errors[:vat_number]) # TODO: This is rather a test for validate_organization_params
    # OrganizationSchema = Dry::Validation.Form do
    #   # required(:party_id).filled(:int?)
    #   # required(:variants).maybe(:str?)
    #   # required(:active).maybe(:bool?)
    # end
  end

  def test_assign_org_roles
    x = interactor.assign_organization_roles(1, [])
    assert_equal(false, x.success)
    assert_equal('Validation error', x.message)
    assert_equal(['You did not choose a role'], x.errors[:roles])

    PartyRepo.any_instance.stubs(:assign_roles).returns(true)
    x = interactor.assign_organization_roles(1, [1, 2, 3])
    assert x.success
    assert_equal('Roles assigned successfully', x.message)
  end

  def test_create_organization
    PartyRepo.any_instance.stubs(:create_organization).returns(id: 1)
    PartyRepo.any_instance.stubs(:find_organization).returns(fake_organization)

    x = interactor.create_organization(invalid_organization)
    assert_equal(false, x.success)
    assert_equal('Validation error', x.message)
    # assert_equal(['must be a string'], x.errors[:vat_number]) # TODO: This is rather a test for validate_organization_params

    x = interactor.create_organization(organization_for_create)
    assert x.success
    assert_instance_of(Organization, x.instance)
    assert_equal('Created organization Test Organization Party', x.message)
  end

  def test_update_organization
    # Fails on invalid update
    x = interactor.update_organization(1, invalid_organization)
    assert_equal(false, x.success)

    # Updates successfully
    success_response = OpenStruct.new(success: true,
                                      instance: nil,
                                      errors: {},
                                      message: 'Roles assigned successfully')
    OrganizationInteractor.any_instance.stubs(:assign_organization_roles).returns(success_response)
    PartyRepo.any_instance.stubs(:update_organization).returns(true)
    OrganizationInteractor.any_instance.stubs(:organization).returns(fake_organization)
    update_attrs = organization_attrs.merge(vat_number: '7894561230')
    x = interactor.update_organization(1, update_attrs)
    expected = interactor.success_response('Updated organization Test Organization Party, Roles assigned successfully', fake_organization)
    assert_equal(expected, x)
    assert x.success

    # Gives validation failed response on fail
    failed_response = OpenStruct.new(success: false,
                                     instance: nil,
                                     errors: {},
                                     message: 'Roles assigned successfully')
    OrganizationInteractor.any_instance.stubs(:assign_organization_roles).returns(failed_response)
    x = interactor.update_organization(1, update_attrs)
    expected = interactor.validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    assert_equal(expected, x)
  end

  def test_delete_organization
    PartyRepo.any_instance.stubs(:delete_organization).returns({success: true})
    OrganizationInteractor.any_instance.stubs(:organization).returns(fake_organization)
    x = interactor.delete_organization(1)
    expected = interactor.success_response('Deleted organization Test Organization Party')
    assert_equal(expected, x)

    PartyRepo.any_instance.stubs(:delete_organization).returns(error: 'something went wrong')
    x = interactor.delete_organization(1)
    expected = interactor.validation_failed_response(OpenStruct.new(messages: 'something went wrong'))
    assert_equal(expected, x)
  end

  def test_assign_organization_roles
    x = interactor.assign_organization_roles(1, [])
    expected = interactor.validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    assert_equal(expected, x)

    PartyRepo.any_instance.stubs(:assign_roles).returns(true)
    x = interactor.assign_organization_roles(1, [1, 2, 3])
    expected = interactor.success_response('Roles assigned successfully')
    assert_equal(expected, x)
  end

  private

  def interactor
    @interactor ||= OrganizationInteractor.new(current_user, {}, {}, {})
  end

  def organization_attrs
    {
      id: 1,
      party_id: 1,
      party_name: 'Test Organization Party',
      parent_id: 1,
      short_description: 'Test Organization Party',
      medium_description: 'Medium Description',
      long_description: 'Long Description',
      vat_number: '789456',
      variants: [],
      active: true,
      role_ids: [1, 2, 3],
      role_names: ['One', 'Two', 'Three'],
      parent_organization: 'Test Parent Organization'
    }
  end

  def organization_for_create
    keys = %i[short_description medium_description long_description vat_number active role_ids]
    organization_attrs.select { |key, _| keys.include?(key) }
  end

  def invalid_organization
    keys = %i[short_description medium_description long_description vat_number active role_ids]
    org_attrs = organization_attrs.select { |key, _| keys.include?(key) }
    org_attrs[:vat_number] = 789456
    org_attrs
  end

  def fake_organization
    Organization.new(organization_attrs)
  end
end