# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module MasterfilesApp
  class PartyRepo < BaseRepo
    build_for_select :organizations,
                     label: :short_description,
                     value: :id,
                     order_by: :short_description
    build_for_select :people,
                     label: :surname,
                     value: :id,
                     order_by: :surname
    build_for_select :roles,
                     label: :name,
                     value: :id,
                     order_by: :name
    build_for_select :customer_types,
                     label: :type_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :type_code
    build_for_select :supplier_types,
                     label: :type_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :type_code

    crud_calls_for :organizations, name: :organization, wrapper: Organization
    crud_calls_for :people, name: :person, wrapper: Person
    crud_calls_for :addresses, name: :address, wrapper: Address
    crud_calls_for :contact_methods, name: :contact_method, wrapper: ContactMethod
    crud_calls_for :customer_types, name: :customer_type, wrapper: CustomerType
    crud_calls_for :customers, name: :customer, wrapper: Customer
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

    def find_party_role(id)
      hash = DB['SELECT party_roles.* , fn_party_role_name(?) AS party_name FROM party_roles WHERE party_roles.id = ?', id, id].first
      return nil if hash.nil?
      PartyRole.new(hash)
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

    def addresses_for_party(party_id: nil, organization_id: nil, person_id: nil, party_role_id: nil, address_type: nil)
      id = party_id unless party_id.nil?
      id = party_id_from_organization(organization_id) unless organization_id.nil?
      id = party_id_from_person(person_id) unless person_id.nil?
      id = party_id_from_party_role(party_role_id) unless party_role_id.nil?

      query = <<~SQL
        SELECT addresses.*, address_types.address_type
        FROM party_addresses
        JOIN addresses ON addresses.id = party_addresses.address_id
        JOIN address_types ON address_types.id = addresses.address_type_id
        WHERE party_addresses.party_id = #{id}
      SQL

      addresses = DB[query].all
      addresses = addresses.select { |r| r[:address_type] == address_type } if address_type
      addresses.map { |r| MasterfilesApp::Address.new(r) }
    end

    def for_select_addresses_for_party(party_id: nil, organization_id: nil, person_id: nil, party_role_id: nil, address_type: nil)
      addresses = addresses_for_party(party_id: party_id, organization_id: organization_id, person_id: person_id, party_role_id: party_role_id, address_type: address_type)
      syms = %i[address_line_1 address_line_2 address_line_3 postal_code city country]
      address_descriptions = []
      addresses.each do |addr|
        set = []
        syms.each do |sym|
          set << addr[sym] if addr[sym]
        end
        address_descriptions << [set.join(', '), addr[:id]]
      end
      address_descriptions
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

    def party_id_from_party_role(id)
      DB[:party_roles].where(id: id).select(:party_id).single_value
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

    # Find the party role for the implementation owner.
    # Requires that the ENV variable "IMPLEMENTATION_OWNER" has been correctly set.
    #
    # @return [MasterfilesApp::PartyRole] the party role entity.
    def implementation_owner_party_role
      query = <<~SQL
        SELECT pr.id, pr.party_id, role_id, organization_id, person_id, pr.active, fn_party_role_name(pr.id) AS party_name
        FROM public.party_roles pr
        JOIN roles r ON r.id = pr.role_id
        LEFT OUTER JOIN organizations o ON o.id = pr.organization_id
        LEFT OUTER JOIN people p ON p.id = pr.person_id
        WHERE r.name = ?
          AND COALESCE(o.short_description, p.first_name || ' ' || p.surname) = ?
          AND pr.active
      SQL
      hash = DB[query, AppConst::ROLE_IMPLEMENTATION_OWNER, ENV[AppConst::ROLE_IMPLEMENTATION_OWNER]].first
      raise Crossbeams::FrameworkError, "IMPLEMENTATION OWNER \"#{ENV[AppConst::ROLE_IMPLEMENTATION_OWNER]}\" is not defined/active" if hash.nil?
      MasterfilesApp::PartyRole.new(hash)
    end

    def assign_roles(id, role_ids, type = 'O')
      return { error: 'Choose at least one role' } if role_ids.empty?
      organization_id = person_id = nil
      if type == 'O'
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
    def for_select_supplier_parties
      parties_except_for_role(MasterfilesApp::SUPPLIER_ROLE)
    end

    def for_select_customer_parties
      parties_except_for_role(MasterfilesApp::CUSTOMER_ROLE)
    end

    def parties_except_for_role(role)
      query = <<~SQL
        SELECT fn_party_name(p.id), p.id
        FROM parties p
        WHERE NOT EXISTS(SELECT id FROM party_roles WHERE party_id = p.id AND role_id = (SELECT id FROM roles WHERE name = '#{role}'))
        AND p.active = true
      SQL
      DB[query].all.map { |r| [r[:fn_party_name] || 'Unknown party name', r[:id]] }
    end

    def create_customer(attrs)
      params = attrs.to_h
      customer_type_ids = params.delete(:customer_type_ids)
      return { error: { customer_type_ids: ['You did not choose any customer types'] } } if customer_type_ids.empty?

      party_id = params.delete(:party_id)
      party_role_id = create_party_role(party_id, AppConst::ROLE_CUSTOMER)[:id]
      return { error: { base: ['You already have this party set up as a customer'] } } if party_role_id.nil?

      customer_id = create(:customers, params.merge(party_role_id: party_role_id))
      customer_type_ids.each do |r_id|
        DB[:customers_customer_types].insert(
          customer_id: customer_id,
          customer_type_id: r_id
        )
      end
      { success: true, id: customer_id }
    end

    def update_customer(id, attrs)
      params = attrs.to_h
      customer_type_ids = params.delete(:customer_type_ids)
      return { error: { customer_type_ids: ['You did not choose any customer types'] } } if customer_type_ids.empty?

      DB[:customers_customer_types].where(customer_id: id).delete
      customer_type_ids.each do |r_id|
        DB[:customers_customer_types].insert(
          customer_id: id,
          customer_type_id: r_id
        )
      end
      update(:customers, id, params)
      { success: true, id: id }
    end

    def delete_customer(id)
      customer = find_hash(:customers, id)
      DB[:customers_customer_types].where(customer_id: id).delete
      DB[:customers].where(id: id).delete
      DB[:party_roles].where(id: customer[:party_role_id]).delete
    end

    def create_supplier(attrs)
      params = attrs.to_h
      supplier_type_ids = params.delete(:supplier_type_ids)
      return { error: { supplier_type_ids: ['You did not choose any supplier types'] } } if supplier_type_ids.empty?

      party_id = params.delete(:party_id)
      party_role_id = create_party_role(party_id, AppConst::ROLE_SUPPLIER)[:id]
      return { error: { base: ['You already have this party set up as a supplier'] } } if party_role_id.nil?

      supplier_id = create(:suppliers, params.merge(party_role_id: party_role_id))
      supplier_type_ids.each do |r_id|
        DB[:suppliers_supplier_types].insert(
          supplier_id: supplier_id,
          supplier_type_id: r_id
        )
      end
      { success: true, id: supplier_id }
    end

    def update_supplier(id, attrs)
      params = attrs.to_h
      supplier_type_ids = params.delete(:supplier_type_ids)
      return { error: { supplier_type_ids: ['You did not choose any supplier types'] } } if supplier_type_ids.empty?

      DB[:suppliers_supplier_types].where(supplier_id: id).delete
      supplier_type_ids.each do |r_id|
        DB[:suppliers_supplier_types].insert(
          supplier_id: id,
          supplier_type_id: r_id
        )
      end
      update(:suppliers, id, params)
      { success: true, id: id }
    end

    def delete_supplier(id)
      supplier = find_hash(:suppliers, id)
      DB[:suppliers_supplier_types].where(supplier_id: id).delete
      DB[:suppliers].where(id: id).delete
      DB[:party_roles].where(id: supplier[:party_role_id]).delete
    end

    def create_party_role(party_id, role_name)
      role_id = DB[:roles].where(name: role_name).first[:id]
      return { success: false, error: { party_role: 'already exists' } } if exists?(:party_roles, party_id: party_id, role_id: role_id)

      org_type = DB[:parties].where(id: party_id).select(:party_type).single_value == 'O'
      respective_id = DB[org_type ? :organizations : :people].where(party_id: party_id).select(:id).single_value

      party_role_id = DB[:party_roles].insert(
        party_id: party_id,
        role_id: DB[:roles].where(name: role_name).select(:id).single_value,
        organization_id: (org_type ? respective_id : nil),
        person_id: (org_type ? nil : respective_id)
      )
      { success: true, id: party_role_id }
    end

    def for_select_customers
      DB['SELECT customers.id, fn_party_role_name(customers.party_role_id) as party_name
          FROM customers'].all.map { |r| [r[:party_name], r[:id]] }
    end

    def for_select_suppliers
      DB['SELECT suppliers.id, fn_party_role_name(suppliers.party_role_id) as party_name
          FROM suppliers'].all.map { |r| [r[:party_name], r[:id]] }
    end

    def find_customer(id)
      hash = find_hash(:customers, id)
      return nil if hash.nil?
      hash[:party_name] = DB['SELECT fn_party_role_name(?)', hash[:party_role_id]].single_value
      hash[:customer_type_ids] = customers_customer_type_ids(id)
      hash[:customer_types] = customers_customer_type_names(hash[:customer_type_ids])
      Customer.new(hash)
    end

    def customers_customer_type_ids(customer_id)
      DB[:customers_customer_types].where(customer_id: customer_id).select_map(:customer_type_id)
    end

    def customers_customer_type_names(customer_type_ids)
      DB[:customer_types].where(id: customer_type_ids).select_map(:type_code)
    end

    def find_supplier(id, by_party_role: false)
      opt = by_party_role ? { party_role_id: id } : { id: id }
      hash = where_hash(:suppliers, opt)
      return nil if hash.nil?
      hash[:party_name] = DB['SELECT fn_party_role_name(?)', hash[:party_role_id]].single_value
      hash[:supplier_type_ids] = suppliers_supplier_type_ids(id)
      hash[:supplier_types] = suppliers_supplier_type_names(hash[:supplier_type_ids])
      Supplier.new(hash)
    end

    def suppliers_supplier_type_ids(supplier_id)
      DB[:suppliers_supplier_types].where(supplier_id: supplier_id).select_map(:supplier_type_id)
    end

    def suppliers_supplier_type_names(supplier_type_ids)
      DB[:supplier_types].where(id: supplier_type_ids).select_map(:type_code)
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
# rubocop:enable Metrics/AbcSize
