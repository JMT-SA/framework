# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

module MasterfilesApp
  class PartyRepo < BaseRepo
    build_for_select :organizations,
                     label: :short_description,
                     value: :id,
                     order_by: :short_description
    build_inactive_select :organizations,
                          label: :short_description,
                          value: :id,
                          order_by: :short_description

    build_for_select :people,
                     label: :surname,
                     value: :id,
                     order_by: :surname
    build_inactive_select :people,
                          label: :surname,
                          value: :id,
                          order_by: :surname

    crud_calls_for :organizations, name: :organization, wrapper: Organization
    crud_calls_for :people, name: :person, wrapper: Person
    crud_calls_for :addresses, name: :address, wrapper: Address
    crud_calls_for :contact_methods, name: :contact_method, wrapper: ContactMethod

    build_for_select :roles,
                     label: :name,
                     value: :id,
                     order_by: :name

    build_for_select :customer_types,
                     label: :type_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :type_code
    build_for_select :customers,
                     label: :erp_customer_number,
                     value: :id,
                     no_active_check: true,
                     order_by: :erp_customer_number

    crud_calls_for :customer_types, name: :customer_type, wrapper: CustomerType
    crud_calls_for :customers, name: :customer, wrapper: Customer

    build_for_select :supplier_types,
                     label: :type_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :type_code
    build_for_select :suppliers,
                     label: :erp_supplier_number,
                     value: :id,
                     no_active_check: true,
                     order_by: :erp_supplier_number

    crud_calls_for :supplier_types, name: :supplier_type, wrapper: SupplierType
    crud_calls_for :suppliers, name: :supplier, wrapper: Supplier

    def for_select_contact_method_types
      DevelopmentApp::ContactMethodTypeRepo.new.for_select_contact_method_types
    end

    def for_select_address_types
      DevelopmentApp::AddressTypeRepo.new.for_select_address_types
    end

    def find_party(id)
      hash = DB['SELECT parties.* , fn_party_name(?) AS party_name FROM parties WHERE parties.id = ?', id, id].first
      return nil if hash.nil?
      Party.new(hash)
    end

    def create_organization(attrs)
      params = attrs.to_h
      role_ids = params.delete(:role_ids)
      return { error: { roles: ['You did not choose a role'] } } if role_ids.empty?
      params[:medium_description] = params[:short_description] unless params[:medium_description]
      params[:long_description] = params[:short_description] unless params[:long_description]
      party_id = DB[:parties].insert(party_type: 'O')
      org_id = DB[:organizations].insert(params.merge(party_id: party_id))
      role_ids.each do |r_id|
        DB[:party_roles].insert(party_id: party_id,
                                role_id: r_id,
                                organization_id: org_id)
      end
      { id: org_id }
    end

    def find_organization(id)
      hash = DB[:organizations].where(id: id).first
      return nil if hash.nil?
      hash = add_dependent_ids(hash)
      hash = add_party_name(hash)
      hash[:role_names] = DB[:roles].where(id: hash[:role_ids]).select_map(:name)
      parent_hash = DB[:organizations].where(id: hash[:parent_id]).first
      hash[:parent_organization] = parent_hash ? parent_hash[:short_description] : nil
      Organization.new(hash)
    end

    def delete_organization(id)
      children = DB[:organizations].where(parent_id: id)
      return { error: 'This organization is set as a parent' } if children.any?
      party_id = party_id_from_organization(id)
      DB[:party_roles].where(party_id: party_id).delete
      DB[:organizations].where(id: id).delete
      delete_party_dependents(party_id)
      { success: true }
    end

    def create_person(attrs)
      params = attrs.to_h
      role_ids = params.delete(:role_ids)
      return { error: 'Choose at least one role' } if role_ids.empty?
      party_id = DB[:parties].insert(party_type: 'P')
      person_id = DB[:people].insert(params.merge(party_id: party_id))
      role_ids.each do |r_id|
        DB[:party_roles].insert(party_id: party_id,
                                role_id: r_id,
                                person_id: person_id)
      end
      { id: person_id }
    end

    def find_person(id)
      hash = find_hash(:people, id)
      return nil if hash.nil?
      hash = add_dependent_ids(hash)
      hash = add_party_name(hash)
      hash[:role_names] = DB[:roles].where(id: hash[:role_ids]).select_map(:name)
      Person.new(hash)
    end

    def delete_person(id)
      party_id = party_id_from_person(id)
      DB[:party_roles].where(party_id: party_id).delete
      DB[:people].where(id: id).delete
      delete_party_dependents(party_id)
    end

    def find_contact_method(id)
      hash = DB[:contact_methods].where(id: id).first
      return nil if hash.nil?
      contact_method_type_id = hash[:contact_method_type_id]
      contact_method_type_hash = DB[:contact_method_types].where(id: contact_method_type_id).first
      hash[:contact_method_type] = contact_method_type_hash[:contact_method_type]
      ContactMethod.new(hash)
    end

    def find_address(id)
      hash = find_hash(:addresses, id)
      return nil if hash.nil?
      address_type_id = hash[:address_type_id]
      address_type_hash = find_hash(:address_types, address_type_id)
      hash[:address_type] = address_type_hash[:address_type]
      Address.new(hash)
    end

    def delete_address(id)
      DB[:party_addresses].where(address_id: id).delete
      DB[:addresses].where(id: id).delete
    end

    def link_addresses(party_id, address_ids)
      existing_ids      = party_address_ids(party_id)
      old_ids           = existing_ids - address_ids
      new_ids           = address_ids - existing_ids

      DB[:party_addresses].where(party_id: party_id).where(address_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:party_addresses].insert(party_id: party_id, address_id: prog_id)
      end
    end

    def delete_contact_method(id)
      DB[:party_contact_methods].where(contact_method_id: id).delete
      DB[:contact_methods].where(id: id).delete
    end

    def link_contact_methods(party_id, contact_method_ids)
      existing_ids      = party_contact_method_ids(party_id)
      old_ids           = existing_ids - contact_method_ids
      new_ids           = contact_method_ids - existing_ids

      DB[:party_contact_methods].where(party_id: party_id).where(contact_method_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:party_contact_methods].insert(party_id: party_id, contact_method_id: prog_id)
      end
    end

    def addresses_for_party(party_id: nil, organization_id: nil, person_id: nil)
      id = party_id unless party_id.nil?
      id = party_id_from_organization(organization_id) unless organization_id.nil?
      id = party_id_from_person(person_id) unless person_id.nil?

      query = <<~SQL
        SELECT addresses.*, address_types.address_type
        FROM party_addresses
        JOIN addresses ON addresses.id = party_addresses.address_id
        JOIN address_types ON address_types.id = addresses.address_type_id
        WHERE party_addresses.party_id = #{id}
      SQL
      DB[query].map { |r| Address.new(r) }
    end

    def contact_methods_for_party(party_id: nil, organization_id: nil, person_id: nil)
      id = party_id unless party_id.nil?
      id = party_id_from_organization(organization_id) unless organization_id.nil?
      id = party_id_from_person(person_id) unless person_id.nil?

      query = <<~SQL
        SELECT contact_methods.*, contact_method_types.contact_method_type
        FROM party_contact_methods
        JOIN contact_methods ON contact_methods.id = party_contact_methods.contact_method_id
        JOIN contact_method_types ON contact_method_types.id = contact_methods.contact_method_type_id
        WHERE party_contact_methods.party_id = #{id}
      SQL
      DB[query].map { |r| ContactMethod.new(r) }
    end

    def party_id_from_organization(id)
      DB[:organizations].where(id: id).select(:party_id).single_value
    end

    def party_id_from_person(id)
      DB[:people].where(id: id).select(:party_id).single_value
    end

    def party_address_ids(party_id)
      DB[:party_addresses].where(party_id: party_id).select_map(:address_id).sort
    end

    def party_contact_method_ids(party_id)
      DB[:party_contact_methods].where(party_id: party_id).select_map(:contact_method_id).sort
    end

    def party_role_ids(party_id)
      DB[:party_roles].where(party_id: party_id).select_map(:role_id).sort
    end

    def assign_roles(id, role_ids, type = 'organization')
      return { error: 'Choose at least one role' } if role_ids.empty?
      organization_id = person_id = nil
      if type == 'organization'
        party = find_organization(id)
        DB[:party_roles].where(organization_id: id).delete
        organization_id = id
      else
        party = find_person(id)
        DB[:party_roles].where(person_id: id).delete
        person_id = id
      end
      role_ids.each do |r_id|
        DB[:party_roles].insert(party_id: party.party_id,
                                organization_id: organization_id,
                                person_id: person_id,
                                role_id: r_id)
      end
    end

    # Customers & Suppliers
    def for_select_parties
      DB[:parties].select_map(:id).map { |id| [DB['SELECT fn_party_name(?)', id].single_value, id] }
    end

    def create_customer(attrs)
      new_attrs = attrs.to_h
      party_id = new_attrs.delete(:party_id)

      party_role_id = create_party_role(party_id, 'CUSTOMER')
      new_attrs[:party_role_id] = party_role_id
      create(:customers, new_attrs)
    end

    def create_supplier(attrs)
      new_attrs = attrs.to_h
      party_id = new_attrs.delete(:party_id)

      party_role_id = create_party_role(party_id, 'SUPPLIER')
      new_attrs[:party_role_id] = party_role_id
      create(:suppliers, new_attrs)
    end

    def create_party_role(party_id, role_name)
      org_type = DB[:parties].where(id: party_id).select(:party_type).single_value == 'O'
      respective_id = DB[org_type ? :organizations : :people].where(party_id: party_id).select(:id).single_value

      DB[:party_roles].insert(party_id: party_id,
                              role_id: DB[:roles].where(name: role_name).select(:id).single_value,
                              organization_id: (org_type ? respective_id : nil),
                              person_id: (org_type ? nil : respective_id))
    end

    private

    def add_party_name(hash)
      party_id = hash[:party_id]
      hash[:party_name] = DB['SELECT fn_party_name(?)', party_id].single_value
      hash
    end

    def add_dependent_ids(hash)
      party_id = hash[:party_id]
      hash[:contact_method_ids] = party_contact_method_ids(party_id)
      hash[:address_ids] = party_address_ids(party_id)
      hash[:role_ids] = party_role_ids(party_id)
      hash
    end

    def delete_party_dependents(party_id)
      DB[:party_addresses].where(party_id: party_id).delete
      DB[:party_contact_methods].where(party_id: party_id).delete
      DB[:parties].where(id: party_id).delete
    end
  end
end
# rubocop:enable Metrics/ClassLength
