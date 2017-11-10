# frozen_string_literal: true

class PartyRepo < RepoBase
  def initialize
    main_table :parties
    table_wrapper Party
    for_select_options label: :party_type,
                       value: :id,
                       order_by: :party_type
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

  def existing_address_ids_for_party(party_id)
    DB[:party_addresses].where(party_id: party_id).select_map(:address_id)
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

  def existing_contact_method_ids_for_party(party_id)
    DB[:party_contact_methods].where(party_id: party_id).select_map(:contact_method_id)
  end

  def all_hash
    DB["SELECT parties.* , fn_party_name(id) AS party_name FROM parties"].all
  end

  def where_hash(args)
    DB["SELECT parties.* , fn_party_name(id) AS party_name FROM parties"].where(args).first
  end

end
