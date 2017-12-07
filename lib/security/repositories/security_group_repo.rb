# frozen_string_literal: true

class SecurityGroupRepo < RepoBase
  build_for_select :security_permissions, label: :security_permission,
                                          value: :id,
                                          order_by: :security_permission
  # build_for_select :security_permissions, label: :security_permission,
  #                                         value: :id,
  #                                         order_by: :security_permission,
  #                                         desc: true,
  #                                         alias: :secperms
  # build_for_select :roles, label: :name,
  #                          value: :id,
  #                          order_by: :id
  def find_with_permissions(id)
    security_group = find(:security_groups, SecurityGroup, id)
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
    DB[:security_groups_security_permissions].where(security_group_id: id).delete
    DB[:security_groups].where(id: id).delete
  end

  def default_security_group_id
    @default_security_group_id ||= begin
                                     query = <<~SQL
                                       SELECT security_group_id
                                       FROM security_groups_security_permissions
                                       JOIN security_permissions ON security_permissions.id = security_groups_security_permissions.security_permission_id
                                       WHERE security_permissions.security_permission = 'read'
                                       LIMIT 1
                                     SQL
                                     DB[query].get(:security_group_id)
                                   end
  end
end
