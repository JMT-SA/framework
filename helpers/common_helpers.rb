module CommonHelpers # rubocop:disable Metrics/ModuleLength
  # Show a Crossbeams::Layout page
  # - The block must return a Crossbeams::Layout::Page
  def show_page(&block)
    @layout = block.yield
    @layout.add_csrf_tag(csrf_tag)
    view('crossbeams_layout_page')
  end

  def show_rmd_page(&block)
    @layout = block.yield
    @layout.add_csrf_tag(csrf_tag)
    view('crossbeams_layout_page', layout: 'layout_rmd')
  end

  # Render a block of Crossbeams::Layout DSL as string.
  #
  # @return [String] HTML layout and content string.
  def render_partial(&block)
    @layout = block.yield
    @layout.add_csrf_tag(csrf_tag)
    @layout.render
  end

  def show_partial(notice: nil, error: nil, &block)
    content = render_partial(&block)
    update_dialog_content(content: content, notice: notice, error: error)
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
    if messages && messages[:base]
      interim = messages
      interim[:base] += Array(base_messages)
      interim
    else
      (messages || {}).merge(base: Array(base_messages))
    end
  end

  # Add validation errors that are not linked to a field in a form.
  # At the same time highlight one or more fields in error
  #
  # @param messages [Hash] the current hash of validation messages.
  # @param base_messages [String, Array] the new messages to be added to the base of the form.
  # @param fields [Array] the fields in the form to be highlighted.
  # @return [Hash] the expanded validation messages.
  def add_base_validation_errors_with_highlights(messages, base_messages, fields)
    if messages && messages[:base_with_highlights]
      interim = messages
      interim[:base_with_highlights][:messages] += Array(base_messages)
      curr = Array(interim[:base_with_highlights][:highlights])
      interim[:base_with_highlights][:highlights] = curr + Array(fields)
      interim
    else
      (messages || {}).merge(base_with_highlights: { messages: Array(base_messages), highlights: fields })
    end
  end

  # Move validation errors that are linked to a specific key up to base.
  # Optionally also  highlight one or more fields in error.
  #
  # @param messages [Hash] the current hash of validation messages.
  # @param keys [String, Array] the existing message keys to be moved to the base of the form.
  # @param highlights [Hash] the fields in the form to be highlighted. Specifiy as a Hash of key: [fields].
  # @return [Hash] the expanded validation messages.
  def move_validation_errors_to_base(messages, keys, highlights: {}) # rubocop:disable Metrics/AbcSize
    interim = messages || {}
    Array(keys).each do |key|
      raise ArgumentError, "Move validation errors - key not present: #{key}" unless interim.key?(key)
      if highlights.key?(key)
        interim[:base_with_highlights] ||= { messages: [], highlights: [] }
        interim[:base_with_highlights][:messages] +=  Array(interim.delete(key))
        interim[:base_with_highlights][:highlights] = Array(interim[:base_with_highlights][:highlights]) + Array(highlights.delete(key))
      else
        interim[:base] ||= []
        interim[:base] += Array(interim.delete(key))
      end
    end
    interim
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

  # Is this a fetch request?
  #
  # @param route [Roda.route] the route.
  # @return [Boolean] true if this is a FETCH request.
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

  # Store the referer URL so it can be redirected to using redirect_to_stored_referer later.
  # The URL is stored in LocalStorage.
  #
  # @param key [symbol] a key to identify the stored url.
  # @return [void]
  def store_last_referer_url(key)
    store_locally("last_referer_url_#{key}".to_sym, request.referer)
  end

  # Redirect to the last_referer_url in local storage.
  #
  # @param route [Roda.route] the current route.
  # @param key [symbol] a key to identify the stored url.
  # @return [void]
  def redirect_to_stored_referer(route, key)
    url = retrieve_from_local_store("last_referer_url_#{key}".to_sym)
    route.redirect url
  end

  # Redirect via JSON to the last_referer_url in local storage.
  #
  # @param route [Roda.route] the current route.
  # @param key [symbol] a key to identify the stored url.
  # @return [void]
  def redirect_via_json_to_stored_referer(key)
    url = retrieve_from_local_store("last_referer_url_#{key}".to_sym)
    redirect_via_json(url)
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

  # Return a JSON response to change the window location to a new URL.
  #
  # Optionally provide a log_url to log to console.
  # - this is useful if urlA builds a report and then the window location
  # is changed to display the output file. The console can be checked to see
  # which url did the work when debugging.
  #
  # @param new_location [string] - the new url.
  # @param log_url [string] - the url to log in the console.
  # @return [JSON] a JSON response.
  def change_window_location_via_json(new_location, log_url = nil)
    res = { location: new_location }
    res[:log_url] = log_url unless log_url.nil?
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
    # res = { updateGridInPlace: Array(ids).map { |i| { id: make_id_correct_type(i), changes: changes } } }
    res = action_update_grid_row(ids, changes: changes)
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  def action_add_grid_row(attrs:)
    { addRowToGrid: { changes: attrs.merge(created_at: Time.now.to_s, updated_at: Time.now.to_s) } }
  end

  def action_update_grid_row(ids, changes:)
    { updateGridInPlace: Array(ids).map { |i| { id: make_id_correct_type(i), changes: changes } } }
  end

  def action_delete_grid_row(id)
    { removeGridRowInPlace: { id: make_id_correct_type(id) } }
  end

  # Add a row to a grid. created_at and updated_at values are provided automatically.
  #
  # @param attrs [Hash] the columns and their values.
  # @param notice [String/Nil] the flash message to show.
  # @return [JSON] the changes to be applied.
  def add_grid_row(attrs:, notice: nil)
    # res = { addRowToGrid: { changes: attrs.merge(created_at: Time.now.to_s, updated_at: Time.now.to_s) } }
    res = action_add_grid_row(attrs: attrs)
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  # Create a list of attributes for passing to the +update_grid_row+ and +add_grid_row+ methods.
  #
  # @param instance [Hash/Dry-type] the instance.
  # @param row_keys [Array] the keys to attributes of the instance.
  # @param extras [Hash] extra key/value combinations to add/replace attributes.
  # @return [Hash] the chosen attributes.
  def select_attributes(instance, row_keys, extras = {})
    Hash[row_keys.map { |k| [k, instance[k]] }].merge(extras)
  end

  def delete_grid_row(id, notice: nil)
    # res = { removeGridRowInPlace: { id: make_id_correct_type(id) } }
    res = action_delete_grid_row(id)
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

  def json_replace_inner_html(dom_id, value, message: nil, keep_dialog_open: false)
    json_actions(OpenStruct.new(type: :replace_inner_html, dom_id: dom_id, value: value), message, keep_dialog_open: keep_dialog_open)
  end

  def json_replace_list_items(dom_id, items, message: nil, keep_dialog_open: false)
    json_actions(OpenStruct.new(type: :replace_list_items, dom_id: dom_id, items: Array(items)), message, keep_dialog_open: keep_dialog_open)
  end

  def json_clear_form_validation(dom_id, message: nil, keep_dialog_open: false)
    json_actions(OpenStruct.new(type: :clear_form_validation, dom_id: dom_id), message, keep_dialog_open: keep_dialog_open)
  end

  def build_json_action(action) # rubocop:disable Metrics/AbcSize
    {
      replace_input_value:    ->(act) { action_replace_input_value(act) },
      replace_inner_html:     ->(act) { action_replace_inner_html(act) },
      replace_select_options: ->(act) { action_replace_select_options(act) },
      replace_multi_options:  ->(act) { action_replace_multi_options(act) },
      replace_list_items:     ->(act) { action_replace_list_items(act) },
      add_grid_row:           ->(act) { action_add_grid_row(attrs: act.attrs) },
      update_grid_row:        ->(act) { action_update_grid_row(act.ids, changes: act.changes) },
      delete_grid_row:        ->(act) { action_delete_grid_row(act.id) },
      clear_form_validation:  ->(act) { action_clear_form_validation(act) }
    }[action.type].call(action)
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

  def action_replace_inner_html(action)
    { replace_inner_html: { id: action.dom_id, value: action.value } }
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

  # Redirect to "Not found" page or return 404 status.
  #
  # @param route [Roda.route] the route.
  # @return [void]
  def handle_not_found(route)
    if fetch?(route)
      response.status = 404
      response.write({}.to_json)
      route.halt
    else
      route.redirect '/not_found'
    end
  end

  # Store a value in local storage for fetching later.
  # Used for storing something per user in one action and retrieving in another action.
  #
  # @param key [Symbol] the key to be used for later retrieval.
  # @param value [Object] the value to stash (use simple Objects)
  # @return [void]
  def store_locally(key, value)
    raise ArgumentError, 'store_locally: key must be a Symbol' unless key.is_a? Symbol
    store = LocalStore.new(current_user.id)
    store.write(key, value)
  end

  # Return a stored value for the current user from local storage (and remove it - read once).
  #
  # @param key [Symbol] the key that was used when stored.
  # @return [Object] the retrieved value.
  def retrieve_from_local_store(key)
    raise ArgumentError, 'store_locally: key must be a Symbol' unless key.is_a? Symbol
    store = LocalStore.new(current_user.id)
    store.read_once(key)
  end

  # Stash a page in local storage for fetching later.
  # Only one page per user can be stashed at a time.
  # Used for storing a page after it has failed validation.
  #
  # @param value [String] the page HTML.
  # @return [void]
  def stash_page(value)
    store_locally(:stashed_page, value)
  end

  # Return the stashed page from local storage.
  # Used to display a page with invalid state instead of the usual new/edit etc. page after a redirect.
  #
  # @return [String] the HTML page.
  def stashed_page
    retrieve_from_local_store(:stashed_page)
  end

  # Create a URL for a report so that it can be called
  # from a spreadsheet app's webquery.
  #
  # @param report_id [Integer] the id of the prepared report.
  # @return [String] the URL.
  def webquery_url_for(report_id)
    port = request.port == '80' || request.port.nil? ? '' : ":#{request.port}"
    "http://#{request.host}#{port}/webquery/#{report_id}"
  end
end
