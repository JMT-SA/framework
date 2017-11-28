# frozen_string_literal: true

class PartyRepo < RepoBase
  def find_party(id)
    hash = DB['SELECT parties.* , fn_party_name(id) AS party_name FROM parties'].where(id: id).first
    return nil if hash.nil?
    Party.new(hash)
  end

  def create_organization(attrs)
    params = attrs.to_h
    role_ids = params.delete(:role_ids)
    return { error: 'Choose at least one role' } if role_ids.empty?
    params[:medium_description] = params[:short_description] unless params[:medium_description]
    params[:long_description] = params[:short_description] unless params[:long_description]
    DB.transaction do
      party_id = DB[:parties].insert(party_type: 'O')
      org_id = DB[:organizations].insert(params.merge(party_id: party_id))
      role_ids.each do |r_id|
        DB[:party_roles].insert(party_id: party_id,
                                role_id: r_id,
                                organization_id: org_id)
      end
      org_id
    end
  end

  def find_organization(id)
    hash = DB[:organizations].where(id: id).first
    return nil if hash.nil?
    hash = add_dependent_ids(hash)
    hash[:role_names] = DB[:roles].where(id: hash[:role_ids]).select_map(:name)
    parent_hash = DB[:organizations].where(id: hash[:parent_id]).first
    hash[:parent_organization] = parent_hash ? parent_hash[:short_description] : nil
    Organization.new(hash)
  end

  def update_organization(id, attrs)
    DB[:organizations].where(id: id).update(attrs.to_h)
  end

  def assign_organization_roles(id, role_ids)
    return { error: 'Choose at least one role' } if role_ids.empty?
    organization = find_organization(id)
    DB.transaction do
      DB[:party_roles].where(organization_id: id).delete
      role_ids.each do |r_id|
        DB[:party_roles].insert(party_id: organization.party_id,
                                role_id: r_id,
                                organization_id: id)
      end
    end
  end

  def delete_organization(id)
    DB.transaction do
      DB[:party_roles].where(organization_id: id).delete
      DB[:security_groups].where(id: id).delete
      DB[:organizations].where(id: id).delete
    end
  end

  def create_person(attrs)
    params = attrs.to_h
    role_ids = params.delete(:role_ids)
    return { error: 'Choose at least one role' } if role_ids.empty?
    DB.transaction do
      party_id = DB[:parties].insert(party_type: 'P')
      person_id = DB[:people].insert(params.merge(party_id: party_id))
      role_ids.each do |r_id|
        DB[:party_roles].insert(party_id: party_id,
                                role_id: r_id,
                                person_id: person_id)
      end
      person_id
    end
  end

  def find_person(id)
    hash = DB[:people].where(id: id).first
    return nil if hash.nil?
    hash = add_dependent_ids(hash)
    hash[:role_names] = DB[:roles].where(id: hash[:role_ids]).select_map(:name)
    Person.new(hash)
  end

  def add_dependent_ids(hash)
    party_id = hash[:party_id]
    hash[:contact_method_ids] = existing_contact_method_ids_for_party(party_id)
    hash[:address_ids] = existing_address_ids_for_party(party_id)
    hash[:role_ids] = existing_role_ids_for_party(party_id)
    hash
  end

  def update_person(id, attrs)
    DB[:people].where(id: id).update(attrs.to_h)
  end

  def assign_person_roles(id, role_ids)
    return { error: 'Choose at least one role' } if role_ids.empty?
    person = find_person(id)
    DB.transaction do
      DB[:party_roles].where(person_id: id).delete
      role_ids.each do |r_id|
        DB[:party_roles].insert(party_id: person.party_id,
                                role_id: r_id,
                                person_id: id)
      end
    end
  end

  def delete_person(id)
    DB.transaction do
      DB[:party_roles].where(person_id: id).delete
      DB[:security_groups].where(id: id).delete
      DB[:people].where(id: id).delete
    end
  end

  def create_contact_method(attrs)
    DB[:contact_methods].insert(attrs.to_h)
  end

  def find_contact_method(id)
    hash = DB[:contact_methods].where(id: id).first
    return nil if hash.nil?
    contact_method_type_id = hash[:contact_method_type_id]
    contact_method_type_hash = DB[:contact_method_types].where(id: contact_method_type_id).first
    hash[:contact_method_type] = contact_method_type_hash[:contact_method_type]
    ContactMethod.new(hash)
  end

  def update_contact_method(id, attrs)
    DB[:contact_methods].where(id: id).update(attrs.to_h)
  end

  def delete_contact_method(id)
    DB[:contact_methods].where(id: id).delete
  end

  def create_address(attrs)
    DB[:addresses].insert(attrs.to_h)
  end

  def find_address(id)
    hash = DB[:addresses].where(id: id).first
    return nil if hash.nil?
    address_type_id = hash[:address_type_id]
    address_type_hash = DB[:address_types].where(id: address_type_id).first
    hash[:address_type] = address_type_hash[:address_type]
    Address.new(hash)
  end

  def update_address(id, attrs)
    DB[:addresses].where(id: id).update(attrs.to_h)
  end

  def delete_address(id)
    DB[:addresses].where(id: id).delete
  end

  def link_addresses(party_id, address_ids)
    existing_ids      = existing_address_ids_for_party(party_id)
    old_ids           = existing_ids - address_ids
    new_ids           = address_ids - existing_ids

    DB.transaction do
      DB[:party_addresses].where(party_id: party_id).where(address_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:party_addresses].insert(party_id: party_id, address_id: prog_id)
      end
    end
  end

  def link_contact_methods(party_id, contact_method_ids)
    existing_ids      = existing_contact_method_ids_for_party(party_id)
    old_ids           = existing_ids - contact_method_ids
    new_ids           = contact_method_ids - existing_ids

    DB.transaction do
      DB[:party_contact_methods].where(party_id: party_id).where(contact_method_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:party_contact_methods].insert(party_id: party_id, contact_method_id: prog_id)
      end
    end
  end

  def existing_address_ids_for_party(party_id)
    DB[:party_addresses].where(party_id: party_id).select_map(:address_id).sort
  end

  def existing_contact_method_ids_for_party(party_id)
    DB[:party_contact_methods].where(party_id: party_id).select_map(:contact_method_id).sort
  end

  def existing_role_ids_for_party(party_id)
    DB[:party_roles].where(party_id: party_id).select_map(:role_id).sort
  end

  def roles_for_select
    set_for_roles
    for_select
  end

  def set_for_roles
    @main_table_name = :roles
    @wrapper = Role
    @select_options = {
      label: :name,
      value: :id,
      order_by: :name
    }
  end

  def contact_method_types_for_select
    set_for_contact_method_types
    for_select
  end

  def set_for_contact_method_types
    @main_table_name = :contact_method_types
    @wrapper = ContactMethodType
    @select_options = {
      label: :contact_method_type,
      value: :id,
      order_by: :contact_method_type
    }
  end

  def people_for_select
    set_for_people
    for_select
  end

  def set_for_people
    @main_table_name = :people
    @wrapper = Person
    @select_options = {
      label: :surname,
      value: :id,
      order_by: :surname
    }
  end

  def organizations_for_select
    set_for_organizations
    for_select
  end

  def set_for_organizations
    @main_table_name = :organizations
    @wrapper = Organization
    @select_options = {
      label: :short_description,
      value: :id,
      order_by: :short_description
    }
  end
end
