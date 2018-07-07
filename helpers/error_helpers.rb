module ErrorHelpers
  def initialize_route_instance_vars
    @cbr_json_response = false
  end

  # For a JSON response, set the content-type header and an instance var.
  # The instance var is used in the error handler plugin.
  def return_json_response
    response['Content-Type'] = 'application/json'
    @cbr_json_response = true
  end

  def show_error(err, fetch_request, json_response)
    case err
    when Crossbeams::AuthorizationError
      show_auth_error(fetch_request, json_response)
    when Sequel::UniqueConstraintViolation
      send_appropriate_error_response('Adding a duplicate', json_response, fetch_request)
    when Sequel::ForeignKeyConstraintViolation
      msg = pg_foreign_key_violation_msg(err)
      send_appropriate_error_response(msg, json_response, fetch_request)
    else
      send_appropriate_error_response(err, json_response, fetch_request)
    end
  end

  def send_appropriate_error_response(err, json_response, fetch_request)
    if json_response
      show_json_error(err)
    elsif fetch_request
      dialog_error(err)
    else
      show_page_error(err)
    end
  end

  def show_auth_error(fetch_request, json_response)
    if json_response
      show_json_permission_error
    elsif fetch_request
      dialog_permission_error
    else
      show_unauthorised
    end
  end

  def dialog_permission_error
    response.status = 403
    "<div class='crossbeams-warning-note'><p><strong>Warning:</strong></p><p>You do not have permission for this task</p></div>"
  end

  def dialog_warning(message)
    "<div class='crossbeams-warning-note'><p><strong>Warning:</strong></p><p>#{message}</p></div>"
  end

  def dialog_error(err, state = nil)
    response.status = 500
    msg = err.respond_to?(:message) ? err.message : err.to_s
    msg = "#{state} - #{msg}" unless state.nil?
    puts err.full_message if err.respond_to?(:full_message) # Log the error too
    return_json_response
    { flash: { error: msg } }.to_json
  end

  def show_unauthorised
    response.status = 403
    view(inline: "<div class='crossbeams-warning-note'><strong>Warning</strong><br>You do not have permission for this task</div>")
  end

  def show_page_info(message)
    view(inline: "<div class='crossbeams-info-note'><p><strong>Note:</strong></p><p>#{message}</p></div>")
  end

  def show_page_warning(message)
    view(inline: "<div class='crossbeams-warning-note'><p><strong>Warning:</strong></p><p>#{message}</p></div>")
  end

  def show_page_success(message)
    view(inline: "<div class='crossbeams-success-note'><p><strong>Success:</strong></p><p>#{message}</p></div>")
  end

  def show_page_error(err)
    message = err.respond_to?(:message) ? err.message : err.to_s
    puts err.full_message if err.respond_to?(:full_message) # Log the error too
    view(inline: "<div class='crossbeams-error-note'><p><strong>Error</strong></p><p>#{message}</p></div>")
  end

  def show_json_notice(message)
    { flash: { notice: message } }.to_json
  end

  def show_json_permission_error
    response.status = 403
    { flash: { error: 'You do not have permission for this task' } }.to_json
  end

  def show_json_error(err, status: 500)
    msg = err.respond_to?(:message) ? err.message : err.to_s
    response.status = status
    if err.respond_to?(:backtrace)
      { exception: err.class.name, flash: { error: "An error occurred: #{msg}" }, backtrace: err.backtrace }.to_json
    else
      { exception: err.class.name, flash: { error: "An error occurred: #{msg}" } }.to_json
    end
  end

  def show_json_exception(err)
    show_json_error(err, status: 200)
  end

  def pg_foreign_key_violation_msg(err)
    msg, det = err.message.delete("\n").split('DETAIL:')
    details = ENV['RACK_ENV'] == 'development' ? "Details: #{det.strip}" : ''
    table = msg.split('"')[1]
    foreign_table = msg.split('"').last
    "A \"#{foreign_table}\" record depends on this \"#{table}\" record. #{details}"
  end
end
