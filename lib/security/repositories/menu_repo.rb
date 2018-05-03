# frozen_string_literal: true

module SecurityApp
  class MenuRepo < RepoBase
    crud_calls_for :functional_areas, name: :functional_area, wrapper: FunctionalArea
    crud_calls_for :programs, name: :program, wrapper: Program, exclude: %i[create update delete]
    crud_calls_for :program_functions, name: :program_function, wrapper: ProgramFunction

    def authorise?(user, programs, sought_permission, functional_area_id)
      raise 'Invalid Functional Area' if functional_area_id.nil?
      prog_ids = program_ids_for(functional_area_id, programs)
      raise 'Invalid Functional Area/Program combination' if prog_ids.empty?

      query = <<~SQL
        SELECT security_permissions.id
        FROM security_groups_security_permissions
        JOIN security_groups ON security_groups.id = security_groups_security_permissions.security_group_id
        JOIN security_permissions ON security_permissions.id = security_groups_security_permissions.security_permission_id
        JOIN programs_users ON programs_users.security_group_id = security_groups.id
        WHERE programs_users.user_id = #{user.id}
        AND security_permissions.security_permission = '#{sought_permission}'
        AND programs_users.program_id IN (#{prog_ids.join(',')})
      SQL
      !DB[query].first.nil?
    end

    def program_ids_for(functional_area_id, programs)
      query = <<~SQL
        SELECT id
        FROM programs
        WHERE programs.functional_area_id = #{functional_area_id}
        AND programs.program_name IN ( '#{programs.map(&:to_s).join("','")}')
      SQL
      DB[query].select_map
    end

    def program_functions_for_select(id)
      query = <<~SQL
        SELECT id, program_function_name
        FROM program_functions
        WHERE program_id = #{id}
        ORDER BY program_function_sequence
      SQL
      DB[query].map { |rec| [rec[:program_function_name], rec[:id]] }
    end

    def functional_area_id_for_name(functional_area_name)
      DB[:functional_areas].where(functional_area_name: functional_area_name).first[:id]
    end

    def create_program(res, webapp)
      DB.transaction do
        id = create(:programs, res)
        create(:programs_webapps, program_id: id, webapp: webapp)
      end
    end

    def update_program(id, res)
      webapps = res.delete(:webapps)
      DB.transaction do
        update(:programs, id, res)
        DB[:programs_webapps].where(program_id: id).delete
        webapps.each do |webapp|
          create(:programs_webapps, program_id: id, webapp: webapp)
        end
      end
    end

    def delete_program(id)
      DB.transaction do
        DB[:programs_webapps].where(program_id: id).delete
        delete(:programs, id)
      end
    end

    def re_order_program_functions(sorted_ids)
      upd = []
      sorted_ids.split(',').each_with_index do |id, index|
        upd << "UPDATE program_functions SET program_function_sequence = #{index + 1} WHERE id = #{id};"
      end
      DB[upd.join].update
    end

    def link_user(user_id, program_ids)
      existing_ids      = existing_prog_ids_for_user(user_id)
      old_ids           = existing_ids - program_ids
      new_ids           = program_ids - existing_ids

      DB[:programs_users].where(user_id: user_id).where(program_id: old_ids).delete
      new_ids.each do |prog_id|
        DB[:programs_users].insert(user_id: user_id, program_id: prog_id, security_group_id: SecurityGroupRepo.new.default_security_group_id)
      end
    end

    def existing_prog_ids_for_user(user_id)
      DB[:programs_users].where(user_id: user_id).select_map(:program_id)
    end

    def available_webapps
      query = 'SELECT DISTINCT webapp FROM programs_webapps'
      DB[query].map { |rec| rec[:webapp] }
    end

    def selected_webapps(program_id)
      query = 'SELECT DISTINCT webapp FROM programs_webapps WHERE program_id = ?'
      DB[query, program_id].map { |rec| rec[:webapp] }
    end

    # PROGRAM FUNCTIONS

    def menu_for_user(user, webapp)
      query = <<~SQL
        SELECT f.id AS functional_area_id, p.id AS program_id, pf.id,
        f.functional_area_name, p.program_sequence, p.program_name, pf.group_name,
        pf.program_function_name, pf.url, pf.program_function_sequence, pf.show_in_iframe
        FROM program_functions pf
        JOIN programs p ON p.id = pf.program_id
        JOIN programs_users pu ON pu.program_id = pf.program_id
        JOIN programs_webapps pw ON pw.program_id = pf.program_id AND pw.webapp = '#{webapp}'
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
      query = <<~SQL
        SELECT DISTINCT group_name
        FROM program_functions
        WHERE program_id = #{program_id}
        ORDER BY group_name
      SQL
      DB[query].map { |r| r[:group_name] }
    end

    def link_users(program_function_id, user_ids)
      existing_ids      = existing_user_ids_for_program_function(program_function_id)
      old_ids           = existing_ids - user_ids
      new_ids           = user_ids - existing_ids

      DB[:program_functions_users].where(program_function_id: program_function_id).where(user_id: old_ids).delete
      new_ids.each do |user_id|
        DB[:program_functions_users].insert(program_function_id: program_function_id, user_id: user_id)
      end
    end

    def existing_user_ids_for_program_function(program_function_id)
      DB[:program_functions_users].where(program_function_id: program_function_id).select_map(:user_id)
    end
  end
end
