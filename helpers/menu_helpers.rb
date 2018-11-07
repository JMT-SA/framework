module MenuHelpers
  def initialize_route_instance_vars
    # @cbr_json_response = false
    check_registered_mobile_device
  end

  # Set instance vars related to registered mobile devices.
  def check_registered_mobile_device
    @registered_mobile_device = false
    @rmd_start_page = nil
    @registered_mobile_device = true if ENV['RUN_FOR_RMD']
    # Here we check the mobile_devices table for is mobile && for start page (possibly other things)
    # First time - read table and store cache on disk - use file from then on. Could config in file?
  end

  def menu_items(webapp)
    return nil if current_user.nil?
    repo      = SecurityApp::MenuRepo.new
    rows      = repo.menu_for_user(current_user, webapp)
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
      progfuncs[row[:program_id]] << { name: row[:program_function_name], group_name: row[:group_name],
                                       url: progfunc_url(row), id: row[:id], func_id: row[:functional_area_id],
                                       prog_id: row[:program_id] }
    end
  end

  def progfunc_url(row)
    row[:show_in_iframe] ? "/iframe/#{row[:id]}" : row[:url]
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
