# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')
require File.join(File.expand_path('../factories', __dir__), 'party_factory')

module MasterfilesApp
  class TestPartyRepo < MiniTestWithHooks
    include PartyFactory

    def test_for_selects
      assert_respond_to repo, :for_select_organizations
      assert_respond_to repo, :for_select_people
      assert_respond_to repo, :for_select_roles
      assert_respond_to repo, :for_select_customer_types
      assert_respond_to repo, :for_select_customers
      assert_respond_to repo, :for_select_supplier_types
      assert_respond_to repo, :for_select_suppliers

      assert_respond_to repo, :for_select_contact_method_types
      assert_respond_to repo, :for_select_address_types
    end

    def test_crud_calls
      test_crud_calls_for :organizations, name: :organization, wrapper: Organization
      test_crud_calls_for :people, name: :person, wrapper: Person
      test_crud_calls_for :addresses, name: :address, wrapper: Address
      test_crud_calls_for :contact_methods, name: :contact_method, wrapper: ContactMethod
      test_crud_calls_for :customer_types, name: :customer_type, wrapper: CustomerType
      test_crud_calls_for :customers, name: :customer, wrapper: Customer
      test_crud_calls_for :supplier_types, name: :supplier_type, wrapper: SupplierType
      test_crud_calls_for :suppliers, name: :supplier, wrapper: Supplier
    end

    def test_find_party
      party_role = create_party_role('O', nil)
      party = repo.find_party(party_role[:party_id])
      assert party
      assert party.party_name
    end

    def test_create_organization
      attrs = {
        # parent_id: nil,
        short_description: Faker::Company.unique.name.to_s,
        medium_description: Faker::Company.name.to_s,
        long_description: Faker::Company.name.to_s,
        vat_number: Faker::Number.number(10),
        active: true,
        role_ids: []
      }
      result_code = repo.create_organization(attrs)
      exp = { roles: ['You did not choose a role'] }
      assert_equal exp, result_code[:error]

      role_id = create_role[:id]
      new_attrs = attrs.merge(role_ids: [role_id],
                              medium_description: nil,
                              long_description: nil)
      result_code = repo.create_organization(new_attrs)
      org = repo.find_hash(:organizations, result_code[:id])
      short_code = org[:short_description]
      assert_equal short_code, org[:medium_description]
      assert_equal short_code, org[:long_description]

      assert repo.exists?(:parties, id: org[:party_id])
      assert repo.exists?(:party_roles,
                          party_id: org[:party_id],
                          role_id: role_id,
                          organization_id: org[:id])
    end

    #         def create_organization(attrs)
    #           params = attrs.to_h
    #           role_ids = params.delete(:role_ids)
    #           return { error: { roles: ['You did not choose a role'] } } if role_ids.empty?
    #           params[:medium_description] = params[:short_description] unless params[:medium_description]
    #           params[:long_description] = params[:short_description] unless params[:long_description]
    #           party_id = DB[:parties].insert(party_type: 'O')
    #           org_id = DB[:organizations].insert(params.merge(party_id: party_id))
    #           role_ids.each do |r_id|
    #             DB[:party_roles].insert(party_id: party_id,
    #                                     role_id: r_id,
    #                                     organization_id: org_id)
    #           end
    #           { id: org_id }
    #         end
    #
    #         def find_organization(id)
    #           hash = DB[:organizations].where(id: id).first
    #           return nil if hash.nil?
    #           hash = add_dependent_ids(hash)
    #           hash = add_party_name(hash)
    #           hash[:role_names] = DB[:roles].where(id: hash[:role_ids]).select_map(:name)
    #           parent_hash = DB[:organizations].where(id: hash[:parent_id]).first
    #           hash[:parent_organization] = parent_hash ? parent_hash[:short_description] : nil
    #           Organization.new(hash)
    #         end
    #
    #         def delete_organization(id)
    #           children = DB[:organizations].where(parent_id: id)
    #           return { error: 'This organization is set as a parent' } if children.any?
    #           party_id = party_id_from_organization(id)
    #           DB[:party_roles].where(party_id: party_id).delete
    #           DB[:organizations].where(id: id).delete
    #           delete_party_dependents(party_id)
    #           { success: true }
    #         end
    #
    #         def create_person(attrs)
    #           params = attrs.to_h
    #           role_ids = params.delete(:role_ids)
    #           return { error: 'Choose at least one role' } if role_ids.empty?
    #           party_id = DB[:parties].insert(party_type: 'P')
    #           person_id = DB[:people].insert(params.merge(party_id: party_id))
    #           role_ids.each do |r_id|
    #             DB[:party_roles].insert(party_id: party_id,
    #                                     role_id: r_id,
    #                                     person_id: person_id)
    #           end
    #           { id: person_id }
    #         end
    #
    #         def find_person(id)
    #           hash = find_hash(:people, id)
    #           return nil if hash.nil?
    #           hash = add_dependent_ids(hash)
    #           hash = add_party_name(hash)
    #           hash[:role_names] = DB[:roles].where(id: hash[:role_ids]).select_map(:name)
    #           Person.new(hash)
    #         end
    #
    #         def delete_person(id)
    #           party_id = party_id_from_person(id)
    #           DB[:party_roles].where(party_id: party_id).delete
    #           DB[:people].where(id: id).delete
    #           delete_party_dependents(party_id)
    #         end
    #
    #         def find_contact_method(id)
    #           hash = DB[:contact_methods].where(id: id).first
    #           return nil if hash.nil?
    #           contact_method_type_id = hash[:contact_method_type_id]
    #           contact_method_type_hash = DB[:contact_method_types].where(id: contact_method_type_id).first
    #           hash[:contact_method_type] = contact_method_type_hash[:contact_method_type]
    #           ContactMethod.new(hash)
    #         end
    #
    #         def find_address(id)
    #           hash = find_hash(:addresses, id)
    #           return nil if hash.nil?
    #           address_type_id = hash[:address_type_id]
    #           address_type_hash = find_hash(:address_types, address_type_id)
    #           hash[:address_type] = address_type_hash[:address_type]
    #           Address.new(hash)
    #         end
    #
    #         def delete_address(id)
    #           DB[:party_addresses].where(address_id: id).delete
    #           DB[:addresses].where(id: id).delete
    #         end
    #
    #         def link_addresses(party_id, address_ids)
    #           existing_ids      = party_address_ids(party_id)
    #           old_ids           = existing_ids - address_ids
    #           new_ids           = address_ids - existing_ids
    #
    #           DB[:party_addresses].where(party_id: party_id).where(address_id: old_ids).delete
    #           new_ids.each do |prog_id|
    #             DB[:party_addresses].insert(party_id: party_id, address_id: prog_id)
    #           end
    #         end
    #
    #         def delete_contact_method(id)
    #           DB[:party_contact_methods].where(contact_method_id: id).delete
    #           DB[:contact_methods].where(id: id).delete
    #         end
    #
    #         def link_contact_methods(party_id, contact_method_ids)
    #           existing_ids      = party_contact_method_ids(party_id)
    #           old_ids           = existing_ids - contact_method_ids
    #           new_ids           = contact_method_ids - existing_ids
    #
    #           DB[:party_contact_methods].where(party_id: party_id).where(contact_method_id: old_ids).delete
    #           new_ids.each do |prog_id|
    #             DB[:party_contact_methods].insert(party_id: party_id, contact_method_id: prog_id)
    #           end
    #         end
    #
    #         def addresses_for_party(party_id: nil, organization_id: nil, person_id: nil)
    #           id = party_id unless party_id.nil?
    #           id = party_id_from_organization(organization_id) unless organization_id.nil?
    #           id = party_id_from_person(person_id) unless person_id.nil?
    #
    #           query = <<~SQL
    #         SELECT addresses.*, address_types.address_type
    #         FROM party_addresses
    #         JOIN addresses ON addresses.id = party_addresses.address_id
    #         JOIN address_types ON address_types.id = addresses.address_type_id
    #         WHERE party_addresses.party_id = #{id}
    #           SQL
    #           DB[query].map { |r| Address.new(r) }
    #         end
    #
    #         def contact_methods_for_party(party_id: nil, organization_id: nil, person_id: nil)
    #           id = party_id unless party_id.nil?
    #           id = party_id_from_organization(organization_id) unless organization_id.nil?
    #           id = party_id_from_person(person_id) unless person_id.nil?
    #
    #           query = <<~SQL
    #         SELECT contact_methods.*, contact_method_types.contact_method_type
    #         FROM party_contact_methods
    #         JOIN contact_methods ON contact_methods.id = party_contact_methods.contact_method_id
    #         JOIN contact_method_types ON contact_method_types.id = contact_methods.contact_method_type_id
    #         WHERE party_contact_methods.party_id = #{id}
    #           SQL
    #           DB[query].map { |r| ContactMethod.new(r) }
    #         end
    #

    def test_party_id_from_organization
      org = create_organization
      actual = repo.party_id_from_organization(org[:id])
      assert_equal org[:party_id], actual
    end

    def test_party_id_from_person
      person = create_person
      actual = repo.party_id_from_person(person[:id])
      assert_equal person[:party_id], actual
    end

    def test_party_address_ids
      party_id = create_party
      address_ids = []
      4.times do
        address_ids << create_party_address(party_id: party_id)
      end
      res = repo.party_address_ids(party_id)
      assert address_ids.sort, res
    end

    def test_party_contact_method_ids
      party_id = create_party
      contact_method_ids = []
      4.times do
        contact_method_ids << create_party_contact_method(party_id: party_id)
      end
      res = repo.party_contact_method_ids(party_id)
      assert contact_method_ids.sort, res
    end

    def test_party_role_ids
      party_id = create_party
      party_role_ids = []
      4.times do
        party_role_ids << create_party_role('O', nil, party_id: party_id)[:id]
      end
      res = repo.party_role_ids(party_id)
      assert party_role_ids.sort, res
    end

    def test_assign_roles
      role_ids = []
      4.times do
        role_ids << create_role[:id]
      end

      org_id = create_organization[:id]
      person_id = create_person[:id]

      result_code = repo.assign_roles(org_id, [], 'O')
      exp = { error: 'Choose at least one role' }
      assert_equal exp, result_code

      repo.assign_roles(org_id, role_ids, 'O')
      party_role_created = repo.where_hash(:party_roles, organization_id: org_id)
      assert party_role_created

      repo.assign_roles(person_id, role_ids, 'P')
      party_role_created = repo.where_hash(:party_roles, person_id: person_id)
      assert party_role_created
    end

    def test_for_select_parties
      5.times do
        create_party
      end
      assert_equal 5, repo.for_select_parties.count
    end

    def test_create_customer
      party_id = create_party
      attrs = {
        party_id: party_id,
        customer_type_ids: [],
        erp_customer_number: 123_456_789
      }
      actual = repo.create_customer(attrs)
      exp = { error: { customer_type_ids: ['You did not choose any customer types'] } }
      assert_equal exp, actual

      type_ids = []
      2.times do
        type_ids << create_customer_type[:id]
      end
      party_role_info = create_party_role('O', AppConst::ROLE_CUSTOMER)
      attrs[:customer_type_ids] = type_ids
      attrs[:party_id] = party_role_info[:party_id]
      actual = repo.create_customer(attrs)
      exp = { error: { base: ['You already have this party set up as a customer'] } }
      assert_equal exp, actual

      attrs[:customer_type_ids] = type_ids
      attrs[:party_id] = party_id
      actual = repo.create_customer(attrs)
      type_links = DB[:customers_customer_types].where(customer_id: actual[:id])
      refute_empty type_links
      assert_equal 2, type_links.count
      assert actual[:success]
    end

    def test_create_supplier
      party_id = create_party
      attrs = {
        party_id: party_id,
        supplier_type_ids: [],
        erp_supplier_number: 123_456_789
      }
      actual = repo.create_supplier(attrs)
      exp = { error: { supplier_type_ids: ['You did not choose any supplier types'] } }
      assert_equal exp, actual

      type_ids = []
      2.times do
        type_ids << create_supplier_type[:id]
      end
      party_role_info = create_party_role('O', AppConst::ROLE_SUPPLIER)
      attrs[:supplier_type_ids] = type_ids
      attrs[:party_id] = party_role_info[:party_id]
      actual = repo.create_supplier(attrs)
      exp = { error: { base: ['You already have this party set up as a supplier'] } }
      assert_equal exp, actual

      attrs[:supplier_type_ids] = type_ids
      attrs[:party_id] = party_id
      actual = repo.create_supplier(attrs)
      type_links = DB[:suppliers_supplier_types].where(supplier_id: actual[:id])
      refute_empty type_links
      assert_equal 2, type_links.count
      assert actual[:success]
    end

    def test_create_party_role
      org = create_organization
      role_id = create_role(name: 'Given Role Name')[:id]
      repo.create_party_role(org[:party_id], 'Given Role Name')

      party_role = repo.where_hash(:party_roles, role_id: role_id)
      assert org[:party_id], party_role[:party_id]
    end

    def test_update_customer
      customer = create_customer
      attrs = {
        customer_type_ids: [],
        erp_customer_number: 123_456_789
      }
      actual = repo.update_customer(customer[:id], attrs)
      exp = { error: { customer_type_ids: ['You did not choose any customer types'] } }
      assert_equal exp, actual

      attrs[:customer_type_ids] = customer[:customer_type_ids]
      assert repo.update_customer(customer[:id], attrs)
    end

    def test_update_supplier
      supplier = create_supplier
      attrs = {
        supplier_type_ids: [],
        erp_supplier_number: 123_456_789
      }
      actual = repo.update_supplier(supplier[:id], attrs)
      exp = { error: { supplier_type_ids: ['You did not choose any supplier types'] } }
      assert_equal exp, actual

      attrs[:supplier_type_ids] = supplier[:supplier_type_ids]
      assert repo.update_supplier(supplier[:id], attrs)
    end

    def test_delete_customer
      customer = create_customer
      assert DB[:customers_customer_types].where(customer_id: customer[:id]).first
      assert DB[:customers].where(id: customer[:id]).first
      assert DB[:party_roles].where(id: customer[:party_role_id]).first

      repo.delete_customer(customer[:id])
      refute DB[:customers_customer_types].where(customer_id: customer[:id]).first
      refute DB[:customers].where(id: customer[:id]).first
      refute DB[:party_roles].where(id: customer[:party_role_id]).first
    end

    def test_delete_supplier
      supplier = create_supplier
      assert DB[:suppliers_supplier_types].where(supplier_id: supplier[:id]).first
      assert DB[:suppliers].where(id: supplier[:id]).first
      assert DB[:party_roles].where(id: supplier[:party_role_id]).first

      repo.delete_supplier(supplier[:id])
      refute DB[:suppliers_supplier_types].where(supplier_id: supplier[:id]).first
      refute DB[:suppliers].where(id: supplier[:id]).first
      refute DB[:party_roles].where(id: supplier[:party_role_id]).first
    end

    def test_customers_customer_type_ids
      customer = create_customer
      actual = repo.customers_customer_type_ids(customer[:id])
      assert_equal customer[:customer_type_ids], actual
    end

    def test_customers_customer_type_names
      customer = create_customer
      actual = repo.customers_customer_type_names(customer[:customer_type_ids])
      exp = DB[:customer_types].where(id: customer[:customer_type_ids][0]).first[:type_code]
      assert_equal exp, actual[0]
    end

    def test_suppliers_supplier_type_ids
      supplier = create_supplier
      actual = repo.suppliers_supplier_type_ids(supplier[:id])
      assert_equal supplier[:supplier_type_ids], actual
    end

    def test_suppliers_supplier_type_names
      supplier = create_supplier
      actual = repo.suppliers_supplier_type_names(supplier[:supplier_type_ids])
      exp = DB[:supplier_types].where(id: supplier[:supplier_type_ids][0]).first[:type_code]
      assert_equal exp, actual[0]
    end

    def test_for_select_customers
      5.times do
        create_customer
      end
      actual = repo.for_select_customers
      assert actual.count == 5
      assert actual[0].is_a?(Array)
      assert actual[0].count == 2
    end

    def test_for_select_suppliers
      5.times do
        create_supplier
      end
      actual = repo.for_select_suppliers
      assert actual.count == 5
      assert actual[0].is_a?(Array)
      assert actual[0].count == 2
    end

    def test_find_customer
      customer = create_customer
      full_customer = repo.find_customer(customer[:id])
      refute full_customer.supplier?
      assert full_customer.party_name
      assert full_customer.customer_type_ids
      assert full_customer.customer_types
      assert full_customer.is_a?(Customer)
    end

    def test_find_supplier
      supplier = create_supplier
      full_supplier = repo.find_supplier(supplier[:id])
      assert full_supplier.supplier?
      assert full_supplier.party_name
      assert full_supplier.supplier_type_ids
      assert full_supplier.supplier_types
      assert full_supplier.is_a?(Supplier)
    end

    def test_add_party_name
      party_role = create_party_role('O', nil)
      hash = repo.find_hash(:parties, party_role[:party_id])
      exp = { party_name: DB['SELECT fn_party_name(?)', party_role[:party_id]].single_value }
      res = repo.send(:add_party_name, hash)
      assert exp[:party_name], res[:party_name]
    end

    def test_add_dependent_ids
      party_id = create_party
      hash = repo.find_hash(:parties, party_id)
      exp = {
        contact_method_ids: [],
        address_ids: [],
        role_ids: []
      }
      2.times do
        exp[:contact_method_ids] << create_party_contact_method(party_id: party_id)
        exp[:address_ids] << create_party_address(party_id: party_id)
        exp[:role_ids] << create_party_role('O', nil, party_id: party_id)[:id]
      end
      res_hash = repo.send(:add_dependent_ids, hash)
      assert exp[:contact_method_ids], res_hash[:contact_method_ids]
      assert exp[:address_ids], res_hash[:address_ids]
      assert exp[:role_ids], res_hash[:role_ids]
    end

    def test_delete_party_dependents
      party_id = create_party
      party_address_id = create_party_address(party_id: party_id)
      party_contact_method_id = create_party_contact_method(party_id: party_id)
      assert repo.find_hash(:party_addresses, party_address_id)
      assert repo.find_hash(:party_contact_methods, party_contact_method_id)
      assert repo.find_hash(:parties, party_id)

      repo.send(:delete_party_dependents, party_id)
      refute repo.find_hash(:party_addresses, party_address_id)
      refute repo.find_hash(:party_contact_methods, party_contact_method_id)
      refute repo.find_hash(:parties, party_id)
    end

    def test_factories
      create_organization
      create_role
      create_party
      create_party_role
      create_person
      create_address
      create_contact_method
      create_party_address
      create_party_contact_method
      create_supplier
      create_customer
    end

    private

    def repo
      PartyRepo.new
    end
  end
end
