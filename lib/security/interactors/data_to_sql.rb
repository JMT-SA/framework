# frozen_string_literal: true

module SecurityApp
  # Generate INSERT SQL commands that can be used to re-create data in another database.
  class DataToSql # rubocop:disable Metrics/ClassLength
    def initialize(webapp)
      @webapp = webapp
    end

    # Make an SQL script that can insert a row and all its dependent rows.
    #
    # @param table [Symbol] a table name. Can be :functional_areas, :programs or :program_functions.
    # @return [String] The SQL script.
    def sql_for(table, id)
      if private_methods.include?(table)
        send(table, id)
      else
        @columns = Hash[dev_repo.table_columns(table)]
        @column_names = dev_repo.table_col_names(table).reject { |c| %i[id active created_at updated_at].include?(c) }
        @insert_stmt = "INSERT INTO #{table} (#{@column_names.map(&:to_s).join(', ')}) VALUES("
        make_extract(table, id)
      end
    end

    private

    # Store these in config - per application
    # The subquery is the subquery to be injected in the INSERT statement.
    # The values gets the key value to be used in the subquery for a particular row.
    LKP_RULES = {
      commodity_group_id: { subquery: 'SELECT id FROM commodity_groups WHERE code = ?', values: 'SELECT code FROM commodity_groups WHERE id = ?' },
      commodity_id: { subquery: 'SELECT id FROM commodities WHERE code = ?', values: 'SELECT code FROM commodities WHERE id = ?' },
      cultivar_group_id: { subquery: 'SELECT id FROM cultivar_groups WHERE cultivar_group_code = ?', values: 'SELECT cultivar_group_code FROM cultivar_groups WHERE id = ?' },
      cultivar_id: { subquery: 'SELECT id FROM cultivars WHERE cultivar_name = ?', values: 'SELECT cultivar_name FROM cultivars WHERE id = ?' } # && commodity?
    }.freeze

    def make_extract(table, id)
      table_records(table, id).each do |rec|
        values = []
        @column_names.each { |col| values << get_insert_value(rec, col) }
        puts "#{@insert_stmt}#{values.join(', ')});"
      end
    end

    def table_records(table, id)
      if id.nil?
        dev_repo.all_hash(table)
      else
        [dev_repo.where_hash(table, id: id)]
      end
    end

    def get_insert_value(rec, col) # rubocop:disable Metrics/AbcSize
      return 'NULL' if rec[col].nil?

      if LKP_RULES.keys.include?(col)
        lookup(col, rec[col])
      elsif %i[integer decimal float].include?(@columns[col][:type])
        rec[col].to_s
      elsif @columns[col][:type] == :boolean
        rec[col].to_s
      else
        "'#{rec[col].to_s.gsub("'", "''")}'" # Need to escape single quotes...
      end
    end

    def lookup(col, val)
      qry = LKP_RULES[col][:values]
      lkp_val = DB[qry, val].get
      "(#{DB[LKP_RULES[col][:subquery], lkp_val].sql})"
    end

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

    def dev_repo
      @dev_repo ||= DevelopmentApp::DevelopmentRepo.new
    end

    def sql_for_f(functional_area)
      <<~SQL
        -- FUNCTIONAL AREA #{functional_area.functional_area_name}
        INSERT INTO functional_areas (functional_area_name, rmd_menu)
        VALUES ('#{functional_area.functional_area_name}', #{functional_area.rmd_menu});
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
