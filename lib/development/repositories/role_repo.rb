class RoleRepo < RepoBase
  def initialize
    main_table :roles
    table_wrapper Role
    for_select_options label: :name,
                       value: :id,
                       order_by: :name
  end
end