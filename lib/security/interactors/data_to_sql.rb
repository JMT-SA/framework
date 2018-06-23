# frozen_string_literal: true

module SecurityApp
  # Generate INSERT SQL commands that can be used to re-create data in another database.
  class DataToSql
    def initialize(webapp)
      @webapp = webapp
    end

    # Make an SQL script that can insert a row and all its dependent rows.
    #
    # @param table [Symbol] a table name. Can be :functional_areas, :programs or :program_functions.
    # @return [String] The SQL script.
    def sql_for(table, id)
      send(table, id)
    end

    private

    def functional_areas(id)
      functional_area = repo.find_functional_area(id)
      sql = []
      sql << sql_for_f(functional_area)
      repo.all_hash(:programs, functional_area_id: id).each do |prog|
        sql << programs(prog[:id])
      end
      sql.join("\n\n")
    end

    def programs(id)
      program         = repo.find_program(id)
      functional_area = repo.find_functional_area(program.functional_area_id)
      sql             = []
      sql << sql_for_p(functional_area, program)
      repo.all_hash(:program_functions, program_id: id).each do |prog_func|
        sql << program_functions(prog_func[:id])
      end
      sql.join("\n\n")
    end

    def program_functions(id)
      program_function = repo.find_program_function(id)
      program          = repo.find_program(program_function.program_id)
      functional_area  = repo.find_functional_area(program.functional_area_id)
      sql_for_pf(functional_area, program, program_function)
    end

    def repo
      @repo ||= MenuRepo.new
    end

    def sql_for_f(functional_area)
      <<~SQL
        -- FUNCTIONAL AREA #{functional_area.functional_area_name}
        INSERT INTO functional_areas (functional_area_name)
        VALUES ('#{functional_area.functional_area_name}');
      SQL
    end

    def sql_for_p(functional_area, program)
      <<~SQL
        -- PROGRAM: #{program.program_name}
        INSERT INTO programs (program_name, program_sequence, functional_area_id)
        VALUES ('#{program.program_name}', #{program.program_sequence},
                (SELECT id FROM functional_areas WHERE functional_area_name = '#{functional_area.functional_area_name}'));

        -- LINK program to webapp
        INSERT INTO programs_webapps (program_id, webapp)
        VALUES ((SELECT id FROM programs
                           WHERE program_name = '#{program.program_name}'
                             AND functional_area_id = (SELECT id
                                                       FROM functional_areas
                                                       WHERE functional_area_name = '#{functional_area.functional_area_name}')),
                                                       '#{@webapp}');
      SQL
    end

    def sql_for_pf(functional_area, program, program_function)
      <<~SQL
        -- PROGRAM FUNCTION #{program_function.program_function_name}
        INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                                       group_name, restricted_user_access, show_in_iframe)
        VALUES ((SELECT id FROM programs WHERE program_name = '#{program.program_name}'
                  AND functional_area_id = (SELECT id FROM functional_areas
                                            WHERE functional_area_name = '#{functional_area.functional_area_name}')),
                '#{program_function.program_function_name}',
                '#{program_function.url}',
                #{program_function.program_function_sequence},
                #{program_function.group_name.nil? ? 'NULL' : "'#{program_function.group_name}'"},
                #{program_function.restricted_user_access},
                #{program_function.show_in_iframe});
      SQL
    end
  end
end
