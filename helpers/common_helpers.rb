module CommonHelpers
  # Show a Crossbeams::Layout page
  # - The block must return a Crossbeams::Layout::Page
  def show_page(&block)
    @layout = block.yield
    @layout.add_csrf_tag(csrf_tag)
    view('crossbeams_layout_page')
  end

  def render_partial(&block)
    @layout = block.yield
    @layout.add_csrf_tag(csrf_tag)
    @layout.render
  end

  def show_partial(&block)
    content = render_partial(&block)
    update_dialog_content(content: content)
  end

  def show_partial_or_page(route, &block)
    page = stashed_page
    if page
      show_page { page }
    elsif fetch?(route)
      show_partial(&block)
    else
      show_page(&block)
    end
  end

  def re_show_form(route, res, url: nil, &block)
    form = block.yield
    if fetch?(route)
      content = render_partial { form }
      update_dialog_content(content: content, error: res.message)
    else
      flash[:error] = res.message
      stash_page(form)
      route.redirect url || '/'
    end
  end

  def show_page_or_update_dialog(route, res, &block)
    if fetch?(route)
      content = render_partial(&block)
      update_dialog_content(content: content, notice: res.message)
    else
      flash[:notice] = res.message
      show_page(&block)
    end
  end

  # Add validation errors that are not linked to a field in a form.
  #
  # @param messages [Hash] the current hash of validation messages.
  # @param base_messages [String, Array] the new messages to be added to the base of the form.
  # @return [Hash] the expanded validation messages.
  def add_base_validation_errors(messages, base_messages)
    (messages || {}).merge(base: Array(base_messages))
  end

  # Add validation errors that are not linked to a field in a form.
  # At the same time highlight one or more fields in error
  #
  # @param messages [Hash] the current hash of validation messages.
  # @param base_messages [String, Array] the new messages to be added to the base of the form.
  # @param fields [Array] the fields in the form to be highlighted.
  # @return [Hash] the expanded validation messages.
  def add_base_validation_errors_with_highlights(messages, base_messages, fields)
    (messages || {}).merge(base_with_highlights: { messages: Array(base_messages), highlights: fields })
  end

  # Selection from a multiselect grid.
  # Returns an array of values.
  def multiselect_grid_choices(params, treat_as_integers: true)
    list = if params.key?(:selection)
             params[:selection][:list]
           else
             params[:list]
           end
    if treat_as_integers
      list.split(',').map(&:to_i)
    else
      list.split(',')
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

  # # Make option tags for a select tag. Optionally pre-select an item and include a blank line.
  # #
  # # @param value [String] the selected option.
  # # @param opts [Array] the option items.
  # # @param with_blank [Boolean] true if the first option tag should be blank.
  # # @return [String] the HTML +option+ tags.
  # def select_options(value, opts, with_blank = true)
  #   ar = []
  #   ar << "<option value=''></option>" if with_blank
  #   opts.each do |opt|
  #     if opt.is_a? Array
  #       text, val = opt
  #     else
  #       val  = opt
  #       text = opt
  #     end
  #     is_sel = val.to_s == value.to_s
  #     ar << "<option value='#{val}'#{is_sel ? ' selected' : ''}>#{text}</option>"
  #   end
  #   ar.join("\n")
  # end

  # Is this a fetch request?
  def fetch?(route)
    route.has_header?('HTTP_X_CUSTOM_REQUEST_TYPE')
  end

  def current_user
    return nil unless session[:user_id]
    @current_user ||= DevelopmentApp::UserRepo.new.find(:users, DevelopmentApp::User, session[:user_id])
  end

  def store_current_functional_area(functional_area_name)
    @functional_area_id = SecurityApp::MenuRepo.new.functional_area_id_for_name(functional_area_name)
  end

  def current_functional_area
    @functional_area_id
  end

  def authorised?(programs, sought_permission, functional_area_id = nil)
    return false unless current_user
    functional_area_id ||= current_functional_area
    prog_repo = SecurityApp::MenuRepo.new
    prog_repo.authorise?(current_user, Array(programs), sought_permission, functional_area_id)
  end

  def auth_blocked?(functional_area_name, programs, sought_permission)
    store_current_functional_area(functional_area_name)
    !authorised?(programs, sought_permission)
  end

  def check_auth!(programs, sought_permission, functional_area_id = nil)
    raise Crossbeams::AuthorizationError unless authorised?(programs, sought_permission, functional_area_id)
  end

  def set_last_grid_url(url, route = nil)
    session[:last_grid_url] = url unless route && fetch?(route)
  end

  def redirect_to_last_grid(route)
    if fetch?(route)
      redirect_via_json(session[:last_grid_url])
    else
      route.redirect session[:last_grid_url]
    end
  end

  def redirect_via_json_to_last_grid
    redirect_via_json(session[:last_grid_url])
  end

  def redirect_via_json(url)
    { redirect: url }.to_json
  end

  def reload_previous_dialog_via_json(url, notice: nil)
    res = { reloadPreviousDialog: url }
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  def load_via_json(url, notice: nil)
    res = { loadNewUrl: url }
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  def make_id_correct_type(id_in)
    if id_in.is_a?(String)
      id_in.scan(/\D/).empty? ? id_in.to_i : id_in
    else
      id_in
    end
  end

  # Update columns in a particular row (or rows) in the grid.
  # If more than one id is provided, all matching rows will
  # receive the same changed values.
  #
  # @param ids [Integer/Array] the id or ids of the row(s) to update.
  # @param changes [Hash] the changed columns and their values.
  # @param notice [String/Nil] the flash message to show.
  # @return [JSON] the changes to be applied.
  def update_grid_row(ids, changes:, notice: nil)
    res = { updateGridInPlace: Array(ids).map { |i| { id: make_id_correct_type(i), changes: changes } } }
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  # Add a row to a grid. created_at and updated_at values are provided automatically.
  #
  # @param attrs [Hash] the columns and their values.
  # @param notice [String/Nil] the flash message to show.
  # @return [JSON] the changes to be applied.
  def add_grid_row(attrs:, notice: nil)
    res = { addRowToGrid: { changes: attrs.merge(created_at: Time.now.to_s, updated_at: Time.now.to_s) } }
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  # Create a list of attributes for passing to the +update_grid_row+ method.
  #
  # @param instance [Hash/Dry-type] the instance.
  # @param row_keys [Array] the keys to attributes of the instance.
  # @param extras [Hash] extra key/value combinations to add/replace attributes.
  # @return [Hash] the chosen attributes.
  def select_attributes(instance, row_keys, extras = {})
    Hash[row_keys.map { |k| [k, instance[k]] }].merge(extras)
  end

  def delete_grid_row(id, notice: nil)
    res = { removeGridRowInPlace: { id: make_id_correct_type(id) } }
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  def update_dialog_content(content:, notice: nil, error: nil)
    res = { replaceDialog: { content: content } }
    res[:flash] = { notice: notice } if notice
    res[:flash] = { error: error } if error
    res.to_json
  end

  def json_replace_select_options(dom_id, options_array, message: nil, keep_dialog_open: false)
    json_actions(OpenStruct.new(type: :replace_select_options, dom_id: dom_id, options_array: options_array), message, keep_dialog_open: keep_dialog_open)
  end

  def json_replace_multi_options(dom_id, options_array, message: nil, keep_dialog_open: false)
    json_actions(OpenStruct.new(type: :replace_multi_options, dom_id: dom_id, options_array: options_array), message, keep_dialog_open: keep_dialog_open)
  end

  def json_replace_input_value(dom_id, value, message: nil, keep_dialog_open: false)
    json_actions(OpenStruct.new(type: :replace_input_value, dom_id: dom_id, value: value), message, keep_dialog_open: keep_dialog_open)
  end

  def json_replace_list_items(dom_id, items, message: nil, keep_dialog_open: false)
    json_actions(OpenStruct.new(type: :replace_list_items, dom_id: dom_id, items: Array(items)), message, keep_dialog_open: keep_dialog_open)
  end

  def json_clear_form_validation(dom_id, message: nil, keep_dialog_open: false)
    json_actions(OpenStruct.new(type: :clear_form_validation, dom_id: dom_id), message, keep_dialog_open: keep_dialog_open)
  end

  # This could be built in a class and receive send messages....
  def build_json_action(action)
    return action_replace_input_value(action) if action.type == :replace_input_value
    return action_replace_select_options(action) if action.type == :replace_select_options
    return action_replace_multi_options(action) if action.type == :replace_multi_options
    return action_replace_list_items(action) if action.type == :replace_list_items
    return action_clear_form_validation(action) if action.type == :clear_form_validation
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

  def action_replace_list_items(action)
    { replace_list_items: { id: action.dom_id, items: action.items } }
  end

  def action_clear_form_validation(action)
    { clear_form_validation: { form_id: action.dom_id } }
  end

  def json_actions(actions, message = nil, keep_dialog_open: false)
    res = { actions: Array(actions).map { |a| build_json_action(a) } }
    res[:flash] = { notice: message } unless message.nil?
    res[:keep_dialog_open] = true if keep_dialog_open
    res.to_json
  end

  def handle_not_found(route)
    if request.xhr?
      "<div class='crossbeams-error-note'><strong>Error</strong><br>The requested resource was not found.</div>"
    else
      route.redirect '/not_found'
    end
  end

  def stash_page(value)
    store = LocalStore.new(current_user.id)
    store.write(:stashed_page, value)
  end

  def stashed_page
    store = LocalStore.new(current_user.id)
    store.read_once(:stashed_page)
  end

  def webquery_url_for(report_id)
    port = request.port == '80' || request.port.nil? ? '' : ":#{request.port}"
    "http://#{request.host}#{port}/webquery/#{report_id}"
  end
end
