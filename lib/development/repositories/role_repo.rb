class RoleRepo < RepoBase
  build_for_select :roles,
                   label: :name,
                   value: :id,
                   order_by: :name
end
