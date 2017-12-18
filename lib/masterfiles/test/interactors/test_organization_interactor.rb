require File.join(File.expand_path('../../../../../test', __FILE__), 'test_helper')
require File.join(File.expand_path('../../fake_repositories/', __FILE__), 'fake_party_repo')

class TestOrganizationInteractor < Minitest::Test

  def test_create_organization
    PartyRepo.any_instance.stubs(:create_organization).returns(id: 1)
    PartyRepo.any_instance.stubs(:find_organization).returns(Organization.new(organization_attrs))

    x = interactor.create_organization(invalid_organization_for_create)
    assert !x.success
    assert_equal('Validation error', x.message)
    assert_equal(['must be a string'], x.errors[:vat_number]) # TODO: This is rather a test for validate_organization_params

    x = interactor.create_organization(organization_for_create)
    assert x.success
    assert_instance_of(Organization, x.instance)
    assert_equal('Created organization Test Organization Party', x.message)
  end

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
    my_org = organization_attrs
    my_org[:parent_id] = '1'
    p my_org
    x = interactor.send(:validate_organization_params, my_org)
    refute_empty x.errors

    org_attrs_without_id = organization_attrs.reject{ |k, _| k == :id }
    x = interactor.send(:validate_organization_params, org_attrs_without_id)
    assert_empty x.errors

    org_attrs_without_short_description = organization_attrs.reject{ |k, _| k == :short_description }
    x = interactor.send(:validate_organization_params, org_attrs_without_short_description)
    refute_empty x.errors

    org_attrs_without_medium_description = organization_attrs.reject{ |k, _| k == :medium_description }
    x = interactor.send(:validate_organization_params, org_attrs_without_medium_description)
    refute_empty x.errors

    org_attrs_without_long_description = organization_attrs.reject{ |k, _| k == :long_description }
    x = interactor.send(:validate_organization_params, org_attrs_without_long_description)
    refute_empty x.errors

    org_attrs_without_long_description = organization_attrs.reject{ |k, _| k == :long_description }
    x = interactor.send(:validate_organization_params, org_attrs_without_long_description)
    refute_empty x.errors

    # OrganizationSchema = Dry::Validation.Form do
    #   optional(:parent_id).maybe(:int?)
    #   required(:short_description).filled(:str?)
    #   required(:medium_description).maybe(:str?)
    #   required(:long_description).maybe(:str?)
    #   required(:vat_number).maybe(:str?)
    #   required(:role_ids).each(:int?)
    #   # required(:party_id).filled(:int?)
    #   # required(:variants).maybe(:str?)
    #   # required(:active).maybe(:bool?)
    # end


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
      role_ids: [1,2,3],
      role_names: ['One', 'Two', 'Three'],
      parent_organization: 'Test Parent Organization'
    }
    keys = %i[short_description medium_description long_description vat_number active role_ids]
    org_attrs = organization_attrs.select { |key, _| keys.include?(key) }
    org_attrs[:vat_number] = 789456
    org_attrs





  end

  #   def validate_organization_params(params)
  #     OrganizationSchema.call(params)
  #   end
  #   def validation_failed_response(validation_results)
  #     OpenStruct.new(success: false,
  #                    instance: {},
  #                    errors: validation_results.messages,
  #                    message: 'Validation error')
  #   end
  #
  #   def failed_response(message, instance = nil)
  #     OpenStruct.new(success: false,
  #                    instance: instance,
  #                    errors: {},
  #                    message: message)
  #   end
  #
  #   def success_response(message, instance = nil)
  #     OpenStruct.new(success: true,
  #                    instance: instance,
  #                    errors: {},
  #                    message: message)
  #   end

  #
  #   def organization(cached = true)
  #     if cached
  #       @organization ||= party_repo.find_organization(@organization_id)
  #     else
  #       @organization = party_repo.find_organization(@organization_id)
  #     end
  #   end
  #
  #   def validate_organization_params(params)
  #     OrganizationSchema.call(params)
  #   end

  # it "creates an organization party"
  # it "creates a person party"

  # it "updates an organization party"
  # it "updates a person party"

  # it "deletes an organization party"
  # it "deletes a person party"

  # it "returns an organization party"
  # it "returns a person party"

  # it "returns all parties"
  # it "returns all organization parties"
  # it "returns all person parties"

  # it "creates a role"
  # it "returns all roles"

  # it "creates an address type"
  # it "returns all address types"

  # it "creates a contact method"
  # it "returns all contact methods"
  #

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
      role_ids: [1,2,3],
      role_names: ['One', 'Two', 'Three'],
      parent_organization: 'Test Parent Organization'
    }
  end

  def organization_for_create
    keys = %i[short_description medium_description long_description vat_number active role_ids]
    organization_attrs.select { |key, _| keys.include?(key) }
  end

  def invalid_organization_for_create
    keys = %i[short_description medium_description long_description vat_number active role_ids]
    org_attrs = organization_attrs.select { |key, _| keys.include?(key) }
    org_attrs[:vat_number] = 789456
    org_attrs
  end
end


# frozen_string_literal: true
#
# class OrganizationInteractor < BaseInteractor
#   def create_organization(params)
#     res = validate_organization_params(params)
#     return validation_failed_response(res) unless res.messages.empty?
#     response = nil
#     DB.transaction do
#       response = party_repo.create_organization(res.to_h)
#     end
#     if response[:id]
#       @organization_id = response[:id]
#       success_response("Created organization #{organization.party_name}", organization)
#     else
#       validation_failed_response(OpenStruct.new(messages: response[:error]))
#     end
#   end
#
#   def update_organization(id, params)
#     @organization_id = id
#     res = validate_organization_params(params)
#     return validation_failed_response(res) unless res.messages.empty?
#     attrs = res.to_h
#     role_ids = attrs.delete(:role_ids)
#     roles_response = assign_organization_roles(@organization_id, role_ids)
#     if roles_response.success
#       DB.transaction do
#         party_repo.update_organization(id, attrs)
#       end
#       success_response("Updated organization #{organization.party_name}, #{roles_response.message}", organization(false))
#     else
#       validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] }))
#     end
#   end
#
#   def delete_organization(id)
#     @organization_id = id
#     name = organization.party_name
#     response = nil
#     DB.transaction do
#       response = party_repo.delete_organization(id)
#     end
#     if response[:success]
#       success_response("Deleted organization #{name}")
#     else
#       validation_failed_response(OpenStruct.new(messages: response[:error]))
#     end
#   end
#
#   def assign_organization_roles(id, role_ids)
#     return validation_failed_response(OpenStruct.new(messages: { roles: ['You did not choose a role'] })) if role_ids.empty?
#     DB.transaction do
#       party_repo.assign_roles(organization_id: id, role_ids: role_ids)
#     end
#     success_response('Roles assigned successfully')
#   end
#
#   private
#
#   def party_repo
#     @party_repo ||= PartyRepo.new
#   end
#
#   def organization(cached = true)
#     if cached
#       @organization ||= party_repo.find_organization(@organization_id)
#     else
#       @organization = party_repo.find_organization(@organization_id)
#     end
#   end
#
#   def validate_organization_params(params)
#     OrganizationSchema.call(params)
#   end
# end
