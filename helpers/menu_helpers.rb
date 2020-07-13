module MenuHelpers
  def initialize_route_instance_vars
    # @cbr_json_response = false
    check_registered_mobile_device
  end

  # Set instance vars related to registered mobile devices.
  def check_registered_mobile_device # rubocop:disable Metrics/AbcSize
    @rmd_start_page = nil
    @rmd_scan_with_camera = false
    @hybrid_device = true
    @registered_mobile_device = true && return if ENV['RUN_FOR_RMD']

    repo = SecurityApp::RegisteredMobileDeviceRepo.new
    res = repo.ip_address_is_rmd? request.ip
    if res.success
      @registered_mobile_device = true
      @rmd_start_page = res.instance.url
      @rmd_scan_with_camera = res.instance.scan_with_camera
      @hybrid_device = res.instance.hybrid_device
    else
      @registered_mobile_device = false
    end
  end

  def menu_items(webapp)
    return nil if current_user.nil?

    repo      = SecurityApp::MenuRepo.new
    rows      = repo.menu_for_user(current_user, webapp)
    build_menu(rows).to_json
  end

  def rmd_menu_items(webapp, as_hash: false)
    return nil if current_user.nil?

    repo      = SecurityApp::MenuRepo.new
    rows      = repo.rmd_menu_for_user(current_user, webapp)
    hash = build_menu(rows)
    as_hash ? hash : hash.to_json
  end

  def render_rmd_menu # rubocop:disable Metrics/AbcSize
    out = ['<select class="mt2 pa2" id="rmd_menu" name="rmd_menu">',
           '<optgroup label="Navigation">',
           '<option value="" selected="selected">Menu choice</option>',
           '</optgroup>']
    menu_items = rmd_menu_items(self.class.name, as_hash: true)
    return '' if menu_items.nil?

    menu_items[:programs].each do |_, prog|
      prog.each do |prg|
        out << %(<optgroup label="#{prg[:name]}">)
        menu_items[:program_functions][prg[:id]].each do |pf|
          out << %(<option value="#{pf[:url]}">#{pf[:name]}</option>)
        end
        out << '</optgroup>'
      end
    end
    out << '</select>'
    out.join("\n")
  end

  def build_funcs(rows)
    funcs = Set.new
    rows.each do |row|
      funcs << { name: row[:functional_area_name], id: row[:functional_area_id] }
    end
    funcs.to_a
  end

  def build_progs(rows, progs, progfuncs) # rubocop:disable Metrics/AbcSize
    rows.each do |row|
      progs[row[:functional_area_id]] << { name: row[:program_name], id: row[:program_id] }
      next unless progfunc_allowed?(row[:hide_if_const_true], row[:hide_if_const_false])

      progfuncs[row[:program_id]] << { name: row[:program_function_name], group_name: row[:group_name],
                                       url: progfunc_url(row), id: row[:id], func_id: row[:functional_area_id],
                                       prog_id: row[:program_id] }
    end
  end

  # A program function can be hidden according to the boolean
  # value of constants in AppConst.
  def progfunc_allowed?(hide_if_true, hide_if_false) # rubocop:disable Metrics/CyclomaticComplexity
    return true if hide_if_true.nil? && hide_if_false.nil?

    ok = true
    (hide_if_true || '').split(',').each do |ht|
      ok = false if app_const_true?(ht)
    end

    (hide_if_false || '').split(',').each do |hf|
      ok = false unless app_const_true?(hf)
    end
    ok
  end

  # Is a constant in AppConst defined and true?
  def app_const_true?(const)
    AppConst.const_defined?(const) && AppConst.const_get(const) == true
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
