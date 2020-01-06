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

    def make_extract(table, id)
      table_records(table, id).each do |rec|
        values = []
        @column_names.each { |col| values << get_insert_value(rec, col) }
        puts "#{@insert_stmt}#{values.join(', ')});"
      end
    end

    def table_records(table, id)
      if id.nil?
        if Crossbeams::Config::MF_TABLES_SELF_REF.keys.include?(table)
          table_sequenced(table, Crossbeams::Config::MF_TABLES_SELF_REF[table])
        else
          dev_repo.all_hash(table)
        end
      else
        [dev_repo.where_hash(table, id: id)]
      end
    end

    def table_sequenced(table, key)
      part1 = dev_repo.all_hash(table, key => nil)
      part2 = dev_repo.all_hash(table, Sequel.~(key => nil))
      part1 + part2
    end

    def get_insert_value(rec, col) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      return 'NULL' if rec[col].nil?

      if Crossbeams::Config::MF_LKP_RULES.keys.include?(col)
        lookup(col, rec[col])
      elsif Crossbeams::Config::MF_LKP_ARRAY_RULES.keys.include?(col)
        lookup_array(col, rec[col])
      elsif Crossbeams::Config::MF_LKP_PARTY_ROLES.include?(col)
        lookup_party_role(rec[col])
      elsif col == :party_id
        lookup_party(rec[col])
      elsif %i[integer decimal float].include?(@columns[col][:type])
        rec[col].to_s
      elsif @columns[col][:type] == :boolean
        rec[col].to_s
      elsif @columns[col][:type] == :jsonb
        "'#{rec[col].to_s.gsub("'", "''").gsub('=>', ': ')}'" # Need to escape single quotes AND convert ruby hashrocket to JSON colon.
      else
        "'#{rec[col].to_s.gsub("'", "''")}'" # Need to escape single quotes...
      end
    end

    def lookup(col, val)
      qry = Crossbeams::Config::MF_LKP_RULES[col][:values]
      lkp_val = DB[qry, val].first&.values
      return 'NULL' if lkp_val.nil?

      "(#{DB[Crossbeams::Config::MF_LKP_RULES[col][:subquery], *lkp_val].sql})"
    end

    def lookup_array(col, val)
      qry = Crossbeams::Config::MF_LKP_ARRAY_RULES[col][:values]
      lkp_val = DB[qry, val.to_a].select_map
      if lkp_val.empty?
        "'{}'"
      else
        "(#{DB[Crossbeams::Config::MF_LKP_ARRAY_RULES[col][:subquery], lkp_val].sql})"
      end
    end

    def lookup_party(val)
      org_code = DB[:organizations].where(party_id: val).get(:short_description)
      if org_code
        "(SELECT party_id FROM organizations WHERE short_description = '#{org_code}')"
      else
        surname, first_name = DB[:people].where(party_id: val).get(%i[surname first_name])
        "(SELECT party_id  FROM people WHERE surname = '#{surname}' AND first_name = '#{first_name}')"
      end
    end

    def lookup_party_role(val) # rubocop:disable Metrics/AbcSize
      pr = dev_repo.where_hash(:party_roles, id: val)
      role_name = DB[:roles].where(id: DB[:party_roles].where(id: val).get(:role_id)).first[:name]
      sel = if pr[:organization_id]
              org_code = DB[:organizations].where(id: pr[:organization_id]).get(:short_description)
              "(SELECT id FROM party_roles WHERE organization_id = (SELECT id FROM organizations WHERE short_description = '#{org_code}') AND role_id = (SELECT id FROM roles WHERE name = '#{role_name}'))"
            else
              surname, first_name = DB[:people].where(id: pr[:person_id]).get(%i[surname first_name])
              "(SELECT id FROM party_roles WHERE person_id = (SELECT id  FROM people WHERE surname = '#{surname}' AND first_name = '#{first_name}') AND role_id = (SELECT id FROM roles WHERE name = '#{role_name}'))"
            end
      sel
    end

    def combined_party(table, party_type, id) # rubocop:disable Metrics/AbcSize
      @columns = Hash[dev_repo.table_columns(table)]
      column_names = dev_repo.table_col_names(table).reject { |c| %i[id active created_at updated_at].include?(c) }
      insert_stmt = "INSERT INTO #{table} (#{column_names.map(&:to_s).join(', ')}) VALUES("
      table_records(table, id).each do |rec| # should sort orgs by parent_id null first
        values = []
        column_names.each do |col|
          values << if col == :party_id
                      '(SELECT MAX(id) FROM parties)'
                    elsif col == :parent_id
                      parent_code = DB[:organizations].where(id: rec[col]).get(:short_description)
                      "(SELECT id FROM  organizations WHERE short_description = '#{parent_code}')"
                    else
                      get_insert_value(rec, col)
                    end
        end
        puts "INSERT INTO parties (party_type) VALUES('#{party_type}');"
        puts "#{insert_stmt}#{values.join(', ')});"
      end
    end

    def organizations(id)
      combined_party(:organizations, 'O', id)
    end

    def people(id)
      combined_party(:people, 'P', id)
    end

    def party_roles(id) # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity
      table = :party_roles
      @columns = Hash[dev_repo.table_columns(table)]
      column_names = dev_repo.table_col_names(table).reject { |c| %i[id active created_at updated_at].include?(c) }
      insert_stmt = "INSERT INTO #{table} (#{column_names.map(&:to_s).join(', ')}) VALUES("
      recs = if id.nil?
               dev_repo.all_hash(table, person_id: nil)
             else
               [dev_repo.where_hash(table, id: id)]
             end
      recs.each do |rec|
        org_code = DB[:organizations].where(id: rec[:organization_id]).get(:short_description)
        values = []
        column_names.each do |col|
          values << if col == :party_id
                      "(SELECT party_id FROM organizations WHERE short_description = '#{org_code}')"
                    else
                      get_insert_value(rec, col)
                    end
        end
        puts "#{insert_stmt}#{values.join(', ')});"
      end

      return unless id.nil?

      recs = if id.nil?
               dev_repo.all_hash(table, organization_id: nil)
             else
               [dev_repo.where_hash(table, id: id)]
             end
      recs.each do |rec|
        surname, first_name = DB[:people].where(id: rec[:person_id]).get(%i[surname first_name])
        values = []
        column_names.each do |col|
          values << if col == :party_id
                      "(SELECT party_id FROM people WHERE surname = '#{surname}' AND first_name = '#{first_name}')"
                    else
                      get_insert_value(rec, col)
                    end
        end
        puts "#{insert_stmt}#{values.join(', ')});"
      end
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

    def party_repo
      @party_repo ||= MasterfilesApp::PartyRepo.new
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
