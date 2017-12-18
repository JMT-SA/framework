require File.join(File.expand_path('../../../../../test', __FILE__), 'test_helper')
require File.join(File.expand_path('../../fake_repositories/', __FILE__), 'fake_party_repo')
# require 'minitest/mock'

# class Book; end
#
# desired_title = 'War and Peace'
# return_value = desired_title
# method = :title
# book_instance_stub = Minitest::Mock.new
# number_of_title_invocations = 2
# number_of_title_invocations.times do
#   book_instance_stub.expect method, return_value
# end
#
# return_value = book_instance_stub
# method_to_redefine = :new
# Book.stub method_to_redefine, return_value do
#   some_book = Book.new
#   puts some_book.title #=> "War and Peace"
#   puts some_book.title #=> "War and Peace"
# end
# book_instance_stub.verify

# require 'minitest/stub_any_instance'



class TestOrganizationInteractor < Minitest::Test

  def test_create_organization
    p "do I get in here"
    PartyRepo.stub_any_instance :create_organization, nil do
      {id: 1}
    end
    x = PartyRepo.new()
    y = x.create_organization(blah: 'blah')
    p y
    # PartyRepo.stub_any_instance :create_organization do
    #   {id: 1}
    # end
    # PartyRepo.send(:const_set, create_organization, FakePartyRepo.create_organization)
    p "after first line"
    organization_attrs = {
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
    keys = [:short_description, :medium_description, :long_description, :vat_number, :active, :role_ids]
    organization_for_create = organization_attrs.select { |key, _| keys.include?(key) }

    assert interactor.create_organization(organization_for_create)
    # PartyRepo.send(:remove_const, :create_organization)
  end

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
  #
  # before do
  #   # exploit Ruby's constant lookup mechanism
  #   # when BookRepository is referenced in Book.find_all_short_and_unread
  #   # then this class will be used instead of the real BookRepository
  #   OrganizationInteractor.send(:const_set, PartyRepo, FakePartyRepo)
  # end
  #
  # after do
  #   # clean up after ourselves so future tests will not be affected
  #   OrganizationInteractor.send(:remove_const, :PartyRepo)
  # end
  #
  # # let(:fake_party_repo) do
  # #   Class.new(BookRepository)
  # # end



  def party_repo_create_organization(attrs)
    { id: 1 }
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
      vat_number: 789456,
      variants: [],
      active: true,
      role_ids: [1,2,3],
      role_names: ['One', 'Two', 'Three'],
      parent_organization: 'Test Parent Organization'
    }
  end

  def organization_for_create
    keys = [:short_description, :medium_description, :long_description, :vat_number, :active, :role_ids]
    organization_attrs.select { |key, _| keys.include?(key) }
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
