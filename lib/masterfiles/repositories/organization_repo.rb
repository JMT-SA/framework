# frozen_string_literal: true

class OrganizationRepo < RepoBase
  def initialize
    main_table :organizations
    table_wrapper Organization
    for_select_options label: :short_description,
                       value: :id,
                       order_by: :short_description
  end

  def create_organization(attrs)
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
    end
  end

  def find_with_permissions(id)
    security_group = find(id)
    domain_obj = DomainSecurityGroup.new(security_group)
    ids = select_values("SELECT security_permission_id FROM security_groups_security_permissions WHERE security_group_id = #{id}")
    domain_obj.security_permissions = DB[:security_permissions].where(id: ids).map { |sp| SecurityPermission.new(sp) }
    domain_obj
  end

  def assign_security_permissions(id, perm_ids)
    return { error: 'Choose at least one permission' } if perm_ids.empty?
    del = "DELETE FROM security_groups_security_permissions WHERE security_group_id = #{id}"
    ins = String.new
    perm_ids.each do |p_id|
      ins << "INSERT INTO security_groups_security_permissions (security_group_id, security_permission_id) VALUES(#{id}, #{p_id});"
    end
    DB.execute(del)
    DB.execute(ins)
    { success: true }
  end

  def delete_with_permissions(id)
    DB.transaction do
      DB[:security_groups_security_permissions].where(security_group_id: id).delete
      DB[:security_groups].where(id: id).delete
    end
  end
end
