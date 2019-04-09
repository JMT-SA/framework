# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength

module MasterfilesApp
  class LocationRepo < BaseRepo
    build_for_select :locations,
                     label: :location_long_code,
                     value: :id,
                     order_by: :location_long_code
    build_inactive_select :locations,
                          label: :location_long_code,
                          value: :id,
                          order_by: :location_long_code

    build_for_select :location_assignments,
                     label: :assignment_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :assignment_code

    build_for_select :location_storage_types,
                     label: :storage_type_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :storage_type_code

    build_for_select :location_types,
                     label: :location_type_code,
                     value: :id,
                     no_active_check: true,
                     order_by: :location_type_code

    crud_calls_for :locations, name: :location
    crud_calls_for :location_assignments, name: :location_assignment, wrapper: LocationAssignment
    crud_calls_for :location_storage_types, name: :location_storage_type, wrapper: LocationStorageType
    crud_calls_for :location_types, name: :location_type, wrapper: LocationType

    def find_location_by(key, val) # rubocop:disable Metrics/AbcSize
      hash = DB[:locations]
             .join(:location_storage_types, id: :primary_storage_type_id)
             .join(:location_types, id: Sequel[:locations][:location_type_id])
             .join(:location_assignments, id: Sequel[:locations][:primary_assignment_id])
             .select(Sequel[:locations].*,
                     Sequel[:location_storage_types][:storage_type_code],
                     Sequel[:location_types][:location_type_code],
                     Sequel[:location_assignments][:assignment_code])
             .where(Sequel[:locations][key] => val).first
      return nil if hash.nil?
      Location.new(hash)
    end

    def find_location(id)
      find_location_by(:id, id)
    end

    def find_location_by_location_long_code(code)
      find_location_by(:location_long_code, code)
    end

    def find_location_by_location_short_code(barcode)
      find_location_by(:location_short_code, barcode)
    end

    def location_exists(location_long_code, location_short_code)
      return failed_response(%(Location "#{location_long_code}" already exists)) if exists?(:locations, location_long_code: location_long_code)
      return failed_response(%(Location with short code "#{location_short_code}" already exists)) if exists?(:locations, location_short_code: location_short_code)
      ok_response
    end

    def location_id_from_long_code(location_long_code)
      DB[:locations].where(location_long_code: location_long_code).get(:id)
    end

    def create_root_location(params)
      id = create_location(params)
      DB[:location_storage_types_locations].insert(location_id: id,
                                                   location_storage_type_id: params[:primary_storage_type_id])
      DB[:location_assignments_locations].insert(location_id: id,
                                                 location_assignment_id: params[:primary_assignment_id])
      DB[:tree_locations].insert(ancestor_location_id: id,
                                 descendant_location_id: id,
                                 path_length: 0)
      id
    end

    def create_child_location(parent_id, res)
      id = create_location(res)
      DB[:location_storage_types_locations].insert(location_id: id,
                                                   location_storage_type_id: res[:primary_storage_type_id])
      DB[:location_assignments_locations].insert(location_id: id,
                                                 location_assignment_id: res[:primary_assignment_id])
      DB.execute(<<~SQL)
        INSERT INTO tree_locations (ancestor_location_id, descendant_location_id, path_length)
        SELECT t.ancestor_location_id, #{id}, t.path_length + 1
        FROM tree_locations AS t
        WHERE t.descendant_location_id = #{parent_id}
        UNION ALL
        SELECT #{id}, #{id}, 0;
      SQL
      id
    end

    def location_has_children(id)
      DB.select(1).where(DB[:tree_locations].where(ancestor_location_id: id).exclude(descendant_location_id: id).exists).one?
    end

    def delete_location(id)
      DB[:tree_locations].where(ancestor_location_id: id).or(descendant_location_id: id).delete
      DB[:location_storage_types_locations].where(location_id: id).delete
      DB[:location_assignments_locations].where(location_id: id).delete
      DB[:locations].where(id: id).delete
    end

    def for_select_location_storage_types_for(id)
      dataset = DB[:location_storage_types_locations].join(:location_storage_types, id: :location_storage_type_id).where(Sequel[:location_storage_types_locations][:location_id] => id)
      select_two(dataset, :storage_type_code, :id)
    end

    def for_select_location_assignments_for(id)
      dataset = DB[:location_assignments_locations].join(:location_assignments, id: :location_assignment_id).where(Sequel[:location_assignments_locations][:location_id] => id)
      select_two(dataset, :assignment_code, :id)
    end

    def link_assignments(id, multiselect_ids)
      return failed_response('Choose at least one assignment') if multiselect_ids.empty?
      location = find_location(id)
      return failed_response('The primary assignment must be included in your selection') unless multiselect_ids.include?(location.primary_assignment_id)

      del = "DELETE FROM location_assignments_locations WHERE location_id = #{id}"
      ins = String.new
      multiselect_ids.each do |m_id|
        ins << "INSERT INTO location_assignments_locations (location_id, location_assignment_id) VALUES(#{id}, #{m_id});"
      end
      DB.execute(del)
      DB.execute(ins)
      ok_response
    end

    def link_storage_types(id, multiselect_ids)
      return failed_response('Choose at least one storage type') if multiselect_ids.empty?
      location = find_location(id)
      return failed_response('The primary storage type must be included in your selection') unless multiselect_ids.include?(location.primary_storage_type_id)

      del = "DELETE FROM location_storage_types_locations WHERE location_id = #{id}"
      ins = String.new
      multiselect_ids.each do |m_id|
        ins << "INSERT INTO location_storage_types_locations (location_id, location_storage_type_id) VALUES(#{id}, #{m_id});"
      end
      DB.execute(del)
      DB.execute(ins)
      ok_response
    end

    def location_long_code_suggestion(ancestor_id, location_type_id)
      sibling_count = DB[:tree_locations].where(path_length: 1).where(ancestor_location_id: ancestor_id).count
      code = ''
      code += "#{find_hash(:locations, ancestor_id)[:location_long_code]}_" unless location_is_root?(ancestor_id)
      code += type_abbreviation(location_type_id) + (sibling_count + 1).to_s
      success_response('ok', code)
    end

    def type_abbreviation(location_type_id)
      find_hash(:location_types, location_type_id)[:short_code]
    end

    def location_is_root?(id)
      DB[:tree_locations].where(descendant_location_id: id).count == 1
    end

    def can_be_moved_location_type_ids
      DB[:location_types].where(can_be_moved: true).select_map(:id)
    end

    def descendants_for_ancestor_id(ancestor_id)
      DB[:tree_locations].where(ancestor_location_id: ancestor_id).select_map(:descendant_location_id)
    end

    def check_location_storage_types(values)
      qry = sql_for_missing_str_values(values, 'location_storage_types', 'storage_type_code')
      res = DB[qry].select_map
      if res.empty?
        ok_response
      else
        failed_response(res.map { |r| "#{r} is not a valid storage type" }.join(', '))
      end
    end

    def check_location_assignments(values)
      qry = sql_for_missing_str_values(values, 'location_assignments', 'assignment_code')
      res = DB[qry].select_map
      if res.empty?
        ok_response
      else
        failed_response(res.map { |r| "#{r} is not a valid assignment" }.join(', '))
      end
    end

    def check_location_types(values)
      qry = sql_for_missing_str_values(values, 'location_types', 'location_type_code')
      res = DB[qry].select_map
      if res.empty?
        ok_response
      else
        failed_response(res.map { |r| "#{r} is not a valid location type" }.join(', '))
      end
    end

    def check_storage_definitions(values)
      qry = sql_for_missing_str_values(values, 'location_storage_definitions', 'storage_definition_code')
      res = DB[qry].select_map
      if res.empty?
        ok_response
      else
        failed_response(res.map { |r| "#{r} is not a valid storage definition" }.join(', '))
      end
    end

    def check_locations(values)
      qry = sql_for_missing_str_values(values, 'locations', 'location_long_code')
      res = DB[qry].select_map
      if res.empty?
        ok_response
      else
        failed_response(res.map { |r| "#{r} is not a valid location" }.join(', '))
      end
    end

    private

    def sql_for_missing_str_values(values, table, column)
      <<~SQL
        WITH v (code) AS (
         VALUES ('#{values.join("'), ('")}')
        )
        SELECT v.code
        FROM v
          LEFT JOIN #{table} i ON i.#{column} = v.code
        WHERE i.id is null;
      SQL
    end
  end
end
# rubocop:enable Metrics/ClassLength
