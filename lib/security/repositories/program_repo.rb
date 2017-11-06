class ProgramRepo < RepoBase
  def initialize
    main_table :programs
    table_wrapper Program
  end

  def authorise?(user, programs, sought_permission)
    query = <<-SQL
    SELECT security_permissions.id
    FROM security_groups_security_permissions
    JOIN security_groups ON security_groups.id = security_groups_security_permissions.security_group_id
    JOIN security_permissions ON security_permissions.id = security_groups_security_permissions.security_permission_id
    JOIN programs_users ON programs_users.security_group_id = security_groups.id
    JOIN programs ON programs.id = programs_users.program_id
    WHERE programs_users.user_id = #{user.id}
    AND security_permissions.security_permission = '#{sought_permission}'
    AND LOWER(programs.program_name) IN ( '#{programs.map(&:to_s).map(&:downcase).join("','")}')
    SQL
    !DB[query].first.nil?
  end

  def program_functions_for_select(id)
    query = <<-SQL
    SELECT id, program_function_name
    FROM program_functions
    WHERE program_id = #{id}
    ORDER BY program_function_sequence
    SQL
    DB[query].map { |rec| [rec[:program_function_name], rec[:id]] }
  end

  def re_order_program_functions(sorted_ids)
    upd = []
    sorted_ids.split(',').each_with_index do |id, index|
      upd << "UPDATE program_functions SET program_function_sequence = #{index + 1} WHERE id = #{id};"
    end
    DB[upd.join].update
  end

  def link_user(user_id, program_ids)
    existing_ids      = existing_ids_for_user(user_id)
    old_ids           = existing_ids - program_ids
    new_ids           = program_ids - existing_ids

    DB.transaction do
      DB[:programs_users].where(user_id: user_id).where(program_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:programs_users].insert(user_id: user_id, program_id: prog_id, security_group_id: SecurityGroupRepo.new.default_security_group_id)
      end
    end
  end

  def existing_ids_for_user(user_id)
    DB[:programs_users].where(user_id: user_id).select_map(:program_id)
  end
end
