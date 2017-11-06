# frozen_string_literal: true

class PersonRepo < RepoBase
  def initialize
    main_table :people
    table_wrapper Person
    for_select_options label: :surname,
                       value: :id,
                       order_by: :surname
  end

  def create(attrs)
    params = attrs.to_h
    role_id = params.delete(:role_id)
    DB.transaction do # BEGIN
      party_id = DB[:parties].insert(party_type: 'P')
      person_id = DB[:people].insert(params.merge(party_id: party_id))
      DB[:party_roles].insert(person_id: person_id,
                              party_id: party_id,
                              role_id: role_id)
      person_id
    end
  end

  def find_with_roles(id)
    person = find(id)
    domain_obj = DomainParty.new(person)
    ids = select_values("SELECT role_id FROM party_roles WHERE person_id = #{id}")
    domain_obj.roles = DB[:roles].where(id: ids).map { |r| Role.new(r) } # :name && :active
    domain_obj
  end

  def assign_roles(id, role_ids)
    return { error: 'Choose at least one role' } if role_ids.empty?
    person = find(id)
    del = "DELETE FROM party_roles WHERE person_id = #{id};"
    ins = String.new
    role_ids.each do |r_id|
      ins << "INSERT INTO party_roles (party_id, role_id, person_id) VALUES(#{person.party_id}, #{r_id}, #{id});"
    end
    DB.transaction do
      DB.execute(del)
      DB.execute(ins)
    end
    { success: true }
  end

  def delete_with_all(id)
    person = find(id)
    DB.transaction do
      DB[:party_roles].where(person_id: id).delete
      DB[:security_groups].where(id: id).delete
    end
  end
end
