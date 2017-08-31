module MenuHelpers
  def menu_items
    return nil if current_user.nil?
    repo      = ProgramFunctionRepo.new
    rows      = repo.menu_for_user(current_user)
    build_menu(rows).to_json
  end

  def build_funcs(rows)
    funcs = Set.new
    rows.each do |row|
      funcs << { name: row[:functional_area_name], id: row[:functional_area_id] }
    end
    funcs.to_a
  end

  def build_progs(rows, progs, progfuncs)
    rows.each do |row|
      progs[row[:functional_area_id]] << { name: row[:program_name], id: row[:program_id] }
      progfuncs[row[:program_id]] << { name: row[:program_function_name], group_name: row[:group_name], url: row[:url], id: row[:id] }
    end
  end

  def build_menu(rows)
    res       = {}
    progs     = Hash.new { |h, k| h[k] = Set.new }
    progfuncs = Hash.new { |h, k| h[k] = [] }
    build_progs(rows, progs, progfuncs)
    res[:functional_areas] = build_funcs(rows)
    res[:programs] = {}
    progs.map { |k, v| res[:programs][k] = v.to_a }
    res[:program_functions] = progfuncs
    res
  end
end
