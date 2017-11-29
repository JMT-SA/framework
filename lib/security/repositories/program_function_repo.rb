class ProgramFunctionRepo < RepoBase
  def menu_for_user(user)
    query = <<-SQL
    SELECT f.id AS functional_area_id, p.id AS program_id, pf.id,
    f.functional_area_name, p.program_sequence, p.program_name, pf.group_name,
    pf.program_function_name, pf.url, pf.program_function_sequence
    FROM program_functions pf
    JOIN programs p ON p.id = pf.program_id
    JOIN programs_users pu ON pu.program_id = pf.program_id
    JOIN functional_areas f ON f.id = p.functional_area_id
    WHERE pu.user_id = #{user.id}
      AND (NOT pf.restricted_user_access OR EXISTS(SELECT user_id FROM program_functions_users
      WHERE program_function_id = pf.id
        AND user_id = #{user.id}))
        AND f.active
        AND p.active
        AND pf.active
    ORDER BY f.functional_area_name, p.program_sequence, p.program_name,
    CASE WHEN pf.group_name IS NULL THEN
      pf.program_function_sequence
    ELSE
      (SELECT MIN(program_function_sequence)
       FROM program_functions
       WHERE program_id = pf.program_id
         AND group_name = pf.group_name)
    END,
    pf.group_name, pf.program_function_sequence
    SQL
    DB[query].all
  end

  def groups_for(program_id)
    query = <<-SQL
    SELECT DISTINCT group_name
    FROM program_functions
    WHERE program_id = #{program_id}
    ORDER BY group_name
    SQL
    DB[query].map { |r| r[:group_name] }
  end

  def link_users(program_function_id, user_ids)
    existing_ids      = existing_ids_for_program_function(program_function_id)
    old_ids           = existing_ids - user_ids
    new_ids           = user_ids - existing_ids

    DB.transaction do
      DB[:program_functions_users].where(program_function_id: program_function_id).where(user_id: old_ids).delete
      new_ids.each do |user_id|
        DB[:program_functions_users].insert(program_function_id: program_function_id, user_id: user_id)
      end
    end
  end

  def existing_ids_for_program_function(program_function_id)
    DB[:program_functions_users].where(program_function_id: program_function_id).select_map(:user_id)
  end
end
