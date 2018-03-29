module CommonHelpers
  # Show a Crossbeams::Layout page
  # - The block must return a Crossbeams::Layout::Page
  def show_page(&block)
    @layout = block.yield
    @layout.add_csrf_tag(csrf_tag)
    view('crossbeams_layout_page')
  end

  def show_partial(&block)
    @layout = block.yield
    @layout.add_csrf_tag(csrf_tag)
    @layout.render
  end

  def show_partial_or_page(partial, &block)
    @layout = block.yield
    @layout.add_csrf_tag(csrf_tag)
    if partial
      @layout.render
    else
      view('crossbeams_layout_page')
    end
  end

  # Selection from a multiselect grid.
  # Returns an array of values.
  def multiselect_grid_choices(params, treat_as_integers: true)
    if treat_as_integers
      params[:selection][:list].split(',').map(&:to_i)
    else
      params[:selection][:list].split(',')
    end
  end

  # Make option tags for a select tag.
  #
  # @param items [Array] the option items.
  # @return [String] the HTML +option+ tags.
  def make_options(items)
    items.map do |item|
      if item.is_a?(Array)
        "<option value=\"#{item.last}\">#{item.first}</option>"
      else
        "<option value=\"#{item}\">#{item}</option>"
      end
    end.join("\n")
  end

  # Make option tags for a select tag. Optionally pre-select an item and include a blank line.
  #
  # @param value [String] the selected option.
  # @param opts [Array] the option items.
  # @param with_blank [Boolean] true if the first option tag should be blank.
  # @return [String] the HTML +option+ tags.
  def select_options(value, opts, with_blank = true)
    ar = []
    ar << "<option value=''></option>" if with_blank
    opts.each do |opt|
      if opt.is_a? Array
        text, val = opt
      else
        val  = opt
        text = opt
      end
      is_sel = val.to_s == value.to_s
      ar << "<option value='#{val}'#{is_sel ? ' selected' : ''}>#{text}</option>"
    end
    ar.join("\n")
  end

  # Is this a fetch request?
  def fetch?(route)
    route.has_header?('HTTP_X_CUSTOM_REQUEST_TYPE')
  end

  def current_user
    return nil unless session[:user_id]
    @current_user ||= UserRepo.new.find(:users, User, session[:user_id])
  end

  def authorised?(programs, sought_permission)
    return false unless current_user
    prog_repo = SecurityApp::MenuRepo.new
    prog_repo.authorise?(current_user, Array(programs), sought_permission)
  end

  def auth_blocked?(programs, sought_permission)
    !authorised?(programs, sought_permission)
  end

  def show_unauthorised
    response.status = 404
    view(inline: "<div class='crossbeams-warning-note'><strong>Warning</strong><br>You do not have permission for this task</div>")
  end

  def can_do_dataminer_admin?
    # TODO: what decides that user can do admin? security role on dm program?
    # program + user -> program_users -> security_group -> security_permissions
    current_user && authorised?(:data_miner, :admin)
    # current_user # && current_user[:department_name] == 'IT'
  end

  def redirect_to_last_grid(route)
    route.redirect session[:last_grid_url]
  end

  def redirect_via_json_to_last_grid
    redirect_via_json(session[:last_grid_url])
  end

  def redirect_via_json(url)
    { redirect: url }.to_json
  end

  def load_via_json(url)
    { loadNewUrl: url }.to_json
  end

  def show_json_notice(message)
    { flash: { notice: message } }.to_json
  end

  def show_json_error(message)
    { flash: { error: message } }.to_json
  end

  def update_grid_row(id, changes:, notice: nil)
    res = { updateGridInPlace: { id: id.to_i, changes: changes } }
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  def delete_grid_row(id_in, notice: nil)
    id = if id_in.is_a?(String)
           id_in.scan(/\D/).empty? ? id_in.to_i : id_in
         else
           id_in
         end
    res = { removeGridRowInPlace: { id: id } }
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  def update_dialog_content(content:, notice: nil, error: nil)
    res = { replaceDialog: { content: content } }
    res[:flash] = { notice: notice } if notice
    res[:flash] = { error: error } if error
    res.to_json
  end

  def show_json_exception(err)
    { exception: err.class.name, flash: { error: "An error occurred: #{err.message}" } }.to_json
  end

  def handle_json_error(err)
    response.status = 500
    { exception: err.class.name, flash: { error: "An error occurred: #{err.message}" } }.to_json
  end

  def json_replace_select_options(dom_id, options_array, message = nil)
    json_actions(OpenStruct.new(type: :replace_select_options, dom_id: dom_id, options_array: options_array), message)
  end

  def json_replace_multi_options(dom_id, options_array, message = nil)
    json_actions(OpenStruct.new(type: :replace_multi_options, dom_id: dom_id, options_array: options_array), message)
  end

  def json_replace_input_value(dom_id, value, message = nil)
    json_actions(OpenStruct.new(type: :replace_input_value, dom_id: dom_id, value: value), message)
  end

  # This could be built in a class and receive send messages....
  def build_json_action(action)
    return action_replace_input_value(action) if action.type == :replace_input_value
    return action_replace_select_options(action) if action.type == :replace_select_options
    return action_replace_multi_options(action) if action.type == :replace_multi_options
  end

  def action_replace_select_options(action)
    { replace_options: { id: action.dom_id, options: action.options_array } }
  end

  def action_replace_multi_options(action)
    { replace_multi_options: { id: action.dom_id, options: action.options_array } }
  end

  def action_replace_input_value(action)
    { replace_input_value: { id: action.dom_id, value: action.value } }
  end

  def json_actions(actions, message = nil)
    res = { actions: Array(actions).map { |a| build_json_action(a) } }
    res[:flash] = { notice: message } unless message.nil?
    res.to_json
  end

  def handle_error(err)
    response.status = 500
    view(inline: "<div class='crossbeams-error-note'><strong>Error</strong><br>#{err}</div>")
  end

  def handle_not_found(route)
    if request.xhr?
      "<div class='crossbeams-error-note'><strong>Error</strong><br>The requested resource was not found.</div>"
    else
      route.redirect '/not_found'
    end
  end

  def dialog_warning(message)
    "<div class='crossbeams-warning-note'><strong>Warning</strong><br>#{message}</div>"
  end

  def dialog_permission_error
    response.status = 404
    "<div class='crossbeams-warning-note'><strong>Warning</strong><br>You do not have permission for this task</div>"
  end

  def dialog_error(err, state = nil)
    response.status = 500
    "<div class='crossbeams-error-note'><strong>#{state || 'ERROR'}</strong><br>#{err}</div>"
  end

  def stash_page(value)
    store = LocalStore.new(current_user.id)
    store.write(:stashed_page, value)
  end

  def stashed_page
    store = LocalStore.new(current_user.id)
    store.read_once(:stashed_page)
  end
end
