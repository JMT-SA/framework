class SecurityGroupRepo < RepoBase
  def initialize
    main_table :security_groups
    table_wrapper SecurityGroup
  end

  def find_with_permissions(id)
    security_group = find(id)
    domain_obj = DomainSecurityGroup.new(security_group)
    ids = select_values("SELECT security_permission_id FROM security_groups_security_permissions WHERE security_group_id = #{id}")
    domain_obj.security_permissions = DB[:security_permissions].where(id: ids).map { |sp| SecurityPermission.new(sp) }
    domain_obj
  end

  def assign_security_permissions(id, perm_ids)
    return { error: 'Choose at least one permission' } if perm_ids.length == 0
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
