class RoleRepo < RepoBase
  build_for_select :roles,
                   label: :name,
                   value: :id,
                   order_by: :name

  def create_role(attrs)
    create(:roles, attrs)
  end

  def update_role(id, attrs)
    update(:roles, id, attrs)
  end

  def delete_role(id)
    delete(:roles, id)
  end
end
