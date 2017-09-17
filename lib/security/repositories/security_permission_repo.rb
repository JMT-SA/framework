class SecurityPermissionRepo < RepoBase
  def initialize
    main_table :security_permissions
    table_wrapper SecurityPermission
    for_select_options label: :security_permission,
                       value: :id,
                       order_by: :security_permission
  end
end
