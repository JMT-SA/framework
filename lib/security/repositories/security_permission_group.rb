class SecurityPermissionRepo < RepoBase
  def initialize
    main_table :security_permissions
    table_wrapper SecurityPermission
  end
end
