class ProgramFunctionRepo < RepoBase
  def initialize
    set_main_table :program_functions
    set_wrapper ProgramFunction
  end

  def menu_for_user(user)
    query = <<-EOQ
    SELECT f.id AS functional_area_id, p.id AS program_id, pf.id,
    f.functional_area_name, p.program_name, pf.group_name, pf.program_function_name,
    pf.url, pf.program_function_sequence
    FROM program_functions pf
    JOIN programs p ON p.id = pf.program_id
    JOIN program_users pu ON pu.program_id = pf.program_id
    JOIN functional_areas f ON f.id = p.functional_area_id
    WHERE pu.user_id = #{user.id}
      AND (NOT pf.restricted_user_access OR EXISTS(SELECT id FROM program_function_users
      WHERE program_function_id = pf.id
        AND user_id = #{user.id}))
        AND f.active
        AND p.active
        AND pf.active
    ORDER BY f.functional_area_name, p.program_name, pf.group_name, pf.program_function_sequence
    EOQ
    DB[query].all
  end

  def groups_for(program_id)
    query = <<-EOQ
    SELECT DISTINCT group_name
    FROM program_functions
    WHERE program_id = #{program_id}
    ORDER BY group_name
    EOQ
    DB[query].map { |r| r[:group_name] }
  end
end
