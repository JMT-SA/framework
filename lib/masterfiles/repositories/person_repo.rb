# frozen_string_literal: true

class PersonRepo < RepoBase
  def initialize
    main_table :people
    table_wrapper Person
    for_select_options label: :surname,
                       value: :id,
                       order_by: :surname
  end

  def create_person(attrs)
    params = attrs.to_h
    role_id = params.delete(:role_id)
    p role_id
    DB.transaction do # BEGIN
      party_id = DB[:parties].insert(party_type: 'P')
      person_id = DB[:people].insert(params.merge(party_id: party_id))
      DB[:party_roles].insert(person_id: person_id,
                              party_id: party_id,
                              role_id: role_id)
    end
  end

  def find_hash(id)
    query = <<-SQL
    SELECT p.*,
    (SELECT array_agg(sub.id) 
     FROM (SELECT id FROM party_roles WHERE party_roles.party_id = p.party_id) sub) AS role_ids
    FROM people p
    WHERE id = #{id}
    SQL
    DB[query].first
  end

  def role_ids
  #   ?
  # repo = PartyRoleRepo.new
  #   repo.find(self.party_id)
  #   DB["SELECT roles.name FROM people JOIN party_roles ON party_roles.party_id = people.party_id JOIN roles ON roles.id = party_roles.role_id"]
    # Array => role_ids

  end
end
