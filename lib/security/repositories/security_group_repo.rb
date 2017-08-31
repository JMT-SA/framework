class SecurityGroupRepo < RepoBase
  def initialize
    main_table :security_groups
    table_wrapper SecurityGroup
  end
end
