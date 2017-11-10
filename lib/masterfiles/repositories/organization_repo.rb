# frozen_string_literal: true

class OrganizationRepo < RepoBase
  def initialize
    main_table :organizations
    table_wrapper Organization
    for_select_options label: :short_description,
                       value: :id,
                       order_by: :short_description
  end

  def create(attrs)
    params = attrs.to_h
    role_id = params.delete(:role_id)
    params[:medium_description] = params[:short_description] unless params[:medium_description]
    params[:long_description] = params[:short_description] unless params[:long_description]
    DB.transaction do # BEGIN
      party_id = DB[:parties].insert(party_type: 'O')
      org_id = DB[:organizations].insert(params.merge(party_id: party_id))
      DB[:party_roles].insert(organization_id: org_id,
                              party_id: party_id,
                              role_id: role_id)
      org_id
    end
  end

  def find_with_roles(id)
    organization = find(id)
    domain_obj = DomainParty.new(organization)
    ids = select_values("SELECT role_id FROM party_roles WHERE organization_id = #{id}")
    domain_obj.roles = DB[:roles].where(id: ids).map { |r| Role.new(r) } # :name && :active
    domain_obj
  end

  def assign_roles(id, role_ids)
    return { error: 'Choose at least one role' } if role_ids.empty?
    organization = find(id)
    del = "DELETE FROM party_roles WHERE organization_id = #{id};"
    ins = String.new
    role_ids.each do |r_id|
      ins << "INSERT INTO party_roles (party_id, role_id, organization_id) VALUES(#{organization.party_id}, #{r_id}, #{id});"
    end
    DB.transaction do
      DB.execute(del)
      DB.execute(ins)
    end
    { success: true }
  end

  def delete_with_all(id)
    organization = find(id)
    DB.transaction do
      DB[:party_roles].where(organization_id: id).delete
      DB[:security_groups].where(id: id).delete
      DB[:organization].where(id: id).delete
    end
  end
end
