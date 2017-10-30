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

  def make_options(ar)
    ar.map do |a|
      if a.is_a?(Array)
        "<option value=\"#{a.last}\">#{a.first}</option>"
      else
        "<option value=\"#{a}\">#{a}</option>"
      end
    end.join("\n")
  end

  # Is this a fetch request?
  def fetch?(r)
    r.has_header?('HTTP_X_CUSTOM_REQUEST_TYPE')
  end

  def current_user
    return nil unless session[:user_id]
    @current_user ||= UserRepo.new.find(session[:user_id])
  end

  def authorised?(programs, sought_permission)
    return false unless current_user
    prog_repo = ProgramRepo.new
    prog_repo.authorise?(current_user, Array(programs), sought_permission)
  end

  def auth_blocked?(programs, sought_permission)
    !authorised?(programs, sought_permission)
  end

  def show_unauthorised
    view(inline: "<div class='crossbeams-warning-note'><strong>Warning</strong><br>You do not have permission for this task</div>")
  end

  def can_do_dataminer_admin?
    # TODO: what decides that user can do admin? security role on dm program?
    # program + user -> program_users -> security_group -> security_permissions
    current_user && authorised?(:data_miner, :admin)
    # current_user # && current_user[:department_name] == 'IT'
  end

  def redirect_to_last_grid(r)
    r.redirect session[:last_grid_url]
  end

  def redirect_via_json_to_last_grid
    redirect_via_json(session[:last_grid_url])
  end

  def redirect_via_json(url)
    { redirect: url }.to_json
  end

  def update_grid_row(id, changes:, notice: nil)
    res = { updateGridInPlace: { id: id.to_i, changes: changes } }
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  def delete_grid_row(id, notice: nil)
    res = { removeGridRowInPlace: { id: id.to_i } }
    res[:flash] = { notice: notice } if notice
    res.to_json
  end

  def update_dialog_content(content:, notice: nil, error: nil)
    res = { replaceDialog: { content: content } }
    res[:flash] = { notice: notice } if notice
    res[:flash] = { error: error } if error
    res.to_json
  end

  def handle_json_error(err)
    response.status = 500
    { exception: err.class.name, flash: { error: "An error occurred: #{err.message}" } }.to_json
  end

  def handle_error(err)
    response.status = 500
    view(inline: "<div class='crossbeams-error-note'><strong>Error</strong><br>#{err}</div>")
  end

  def handle_not_found(r)
    if request.xhr?
      "<div class='crossbeams-error-note'><strong>Error</strong><br>The requested resource was not found.</div>"
    else
      r.redirect '/not_found'
    end
  end

  def dialog_permission_error
    response.status = 404
    "<div class='crossbeams-warning-note'><strong>Warning</strong><br>You do not have permission for this task</div>"
  end

  def dialog_error(e, state = nil)
    response.status = 500
    "<div class='crossbeams-error-note'><strong>#{state || 'ERROR'}</strong><br>#{e}</div>"
  end
end
