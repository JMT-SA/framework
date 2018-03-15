require File.join(File.expand_path('../../../../../test', __FILE__), 'test_helper')

class TestPersonInteractor < Minitest::Test
  def test_party_repo
    x = interactor.send(:party_repo)
    assert x.is_a?(PartyRepo)
  end

  def test_person
    PartyRepo.any_instance.stubs(:find_person).returns(Person.new(person_attrs))
    x = interactor.send(:person)
    assert x.is_a?(Person)
  end

  def test_validate_person_params
    x = interactor.send(:validate_person_params, person_attrs)
    assert_empty x.errors

    # optional(:id).filled(:int?)
    prsn_attrs_without_id = person_attrs.reject { |k, _| k == :id }
    x = interactor.send(:validate_person_params, prsn_attrs_without_id)
    assert_empty x.errors

    # required(:surname).filled(:str?)
    prsn_attrs_without_surname = person_attrs.reject { |k, _| k == :surname }
    x = interactor.send(:validate_person_params, prsn_attrs_without_surname)
    assert_equal(['is missing'], x.errors[:surname])
    refute_empty x.errors

    prsn_attrs_without_surname[:surname] = 1
    x = interactor.send(:validate_person_params, prsn_attrs_without_surname)
    refute_empty x.errors
    expected = {surname: ['must be a string']}
    assert_equal(expected, x.errors)

    # required(:first_name).filled(:str?)
    prsn_attrs_without_first_name = person_attrs.reject { |k, _| k == :first_name }
    x = interactor.send(:validate_person_params, prsn_attrs_without_first_name)
    assert_equal(['is missing'], x.errors[:first_name])
    refute_empty x.errors

    prsn_attrs_without_first_name[:first_name] = 1
    x = interactor.send(:validate_person_params, prsn_attrs_without_first_name)
    refute_empty x.errors
    expected = {first_name: ['must be a string']}
    assert_equal(expected, x.errors)

    # required(:title).filled(:str?)
    prsn_attrs_without_title = person_attrs.reject { |k, _| k == :title }
    x = interactor.send(:validate_person_params, prsn_attrs_without_title)
    assert_equal(['is missing'], x.errors[:title])
    refute_empty x.errors

    prsn_attrs_without_title[:title] = 1
    x = interactor.send(:validate_person_params, prsn_attrs_without_title)
    refute_empty x.errors
    expected = {title: ['must be a string']}
    assert_equal(expected, x.errors)

    # required(:vat_number).maybe(:str?)
    prsn_attrs_without_vat_number = person_attrs.reject { |k, _| k == :vat_number }
    x = interactor.send(:validate_person_params, prsn_attrs_without_vat_number)
    assert_equal(['is missing'], x.errors[:vat_number])
    refute_empty x.errors
    prsn_attrs_without_vat_number[:vat_number] = '1'
    x = interactor.send(:validate_person_params, prsn_attrs_without_vat_number)
    assert_empty x.errors
    prsn_attrs_without_vat_number[:vat_number] = 1
    x = interactor.send(:validate_person_params, prsn_attrs_without_vat_number)
    expected = {vat_number: ['must be a string']}
    assert_equal(expected, x.errors)

    # required(:role_ids).each(:int?)
    prsn_attrs_without_role_ids = person_attrs.reject { |k, _| k == :role_ids }
    x = interactor.send(:validate_person_params, prsn_attrs_without_role_ids)
    assert_equal(['is missing'], x.errors[:role_ids])
    refute_empty x.errors
    prsn_attrs_without_role_ids[:role_ids] = ['String one', 'String two', 'String three']
    x = interactor.send(:validate_person_params, prsn_attrs_without_role_ids)
    refute_empty x.errors
    expected = { role_ids: { 0 => ['must be an integer'], 1 => ['must be an integer'], 2 => ['must be an integer'] } }
    assert_equal(expected, x.errors)
  end

  def test_assign_prsn_roles
    x = interactor.assign_person_roles(1, [])
    assert_equal(false, x.success)
    assert_equal('Validation error', x.message)
    assert_equal(['You did not choose a role'], x.errors[:roles])

    PartyRepo.any_instance.stubs(:assign_roles).returns(true)
    x = interactor.assign_person_roles(1, [1, 2, 3])
    assert x.success
    assert_equal('Roles assigned successfully', x.message)
  end

  def test_create_person
    PartyRepo.any_instance.stubs(:create_person).returns(id: 1)
    PartyRepo.any_instance.stubs(:find_person).returns(fake_person)

    x = interactor.create_person(invalid_person)
    assert_equal(false, x.success)
    assert_equal('Validation error', x.message)

    x = interactor.create_person(person_for_create)
    assert x.success
    assert_instance_of(Person, x.instance)
    assert_equal('Created person Title First Name Surname', x.message)
  end

  def test_update_person
    # Fails on invalid update
    x = interactor.update_person(1, invalid_person)
    assert_equal(false, x.success)

    # Updates successfully
    success_response = OpenStruct.new(success: true,
                                      instance: nil,
                                      errors: {},
                                      message: 'Roles assigned successfully')
    PersonInteractor.any_instance.stubs(:assign_person_roles).returns(success_response)
    PartyRepo.any_instance.stubs(:update_person).returns(true)
    PersonInteractor.any_instance.stubs(:person).returns(fake_person)
    update_attrs = person_attrs.merge(vat_number: '7894561230')
    x = interactor.update_person(1, update_attrs)
    expected = interactor.success_response('Updated person Title First Name Surname, Roles assigned successfully', fake_person)
    assert_equal(expected, x)
    assert x.success

    # Gives validation failed response on fail
    failed_response = OpenStruct.new(success: false,
                                     instance: nil,
                                     errors: {},
                                     message: 'Roles assigned successfully')
    PersonInteractor.any_instance.stubs(:assign_person_roles).returns(failed_response)
    x = interactor.update_person(1, update_attrs)
    expected = interactor.validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    assert_equal(expected, x)
  end

  def test_delete_person
    PartyRepo.any_instance.stubs(:delete_person).returns({success: true})
    PersonInteractor.any_instance.stubs(:person).returns(fake_person)
    x = interactor.delete_person(1)
    expected = interactor.success_response('Deleted person Title First Name Surname')
    assert_equal(expected, x)
  end

  def test_assign_person_roles
    x = interactor.assign_person_roles(1, [])
    expected = interactor.validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
    assert_equal(expected, x)

    PartyRepo.any_instance.stubs(:assign_roles).returns(true)
    x = interactor.assign_person_roles(1, [1, 2, 3])
    expected = interactor.success_response('Roles assigned successfully')
    assert_equal(expected, x)
  end

  private

  def interactor
    @interactor ||= PersonInteractor.new(current_user, {}, {}, {})
  end

  def person_attrs
    {
      id: 1,
      party_id: 1,
      party_name: 'Title First Name Surname',
      surname: 'Surname',
      first_name: 'First Name',
      title: 'Title',
      vat_number: '789456',
      active: true,
      role_ids: [1, 2, 3],
      role_names: ['One', 'Two', 'Three'],
      address_ids: [1, 2, 3],
      contact_method_ids: [1, 2, 3]
    }
  end

  def person_for_create
    keys = %i[title first_name surname vat_number active role_ids]
    person_attrs.select { |key, _| keys.include?(key) }
  end

  def invalid_person
    keys = %i[title first_name surname vat_number active role_ids]
    prsn_attrs = person_attrs.select { |key, _| keys.include?(key) }
    prsn_attrs[:vat_number] = 789456
    prsn_attrs
  end

  def fake_person
    Person.new(person_attrs)
  end
end
