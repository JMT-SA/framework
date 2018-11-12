module ErrorHelpers
  # For a JSON response, set the content-type header and an instance var.
  # The instance var is used in the error handler plugin.
  # @return [void]
  def return_json_response
    response['Content-Type'] = 'application/json'
  end

  # Formats an error for display in the browser.
  #
  # @param err [Exception, String] the error object or an error message.
  # @param fetch_request [Boolean] is the error to be displayed for a fetch or normal request.
  # @return [String, JSON] the error as HTML or JSON.
  def show_error(err, fetch_request)
    case err
    when Crossbeams::AuthorizationError
      show_auth_error(fetch_request)
    when Crossbeams::TaskNotPermittedError
      show_task_not_permitted_error(fetch_request, err)
    when Sequel::UniqueConstraintViolation
      send_appropriate_error_response('Adding a duplicate', fetch_request)
    when Sequel::ForeignKeyConstraintViolation
      msg = pg_foreign_key_violation_msg(err)
      send_appropriate_error_response(msg, fetch_request)
    else
      send_appropriate_error_response(err, fetch_request)
    end
  end

  # Route the error-display for page/fetch calls.
  #
  # @param err [Exception, String] the error.
  # @param fetch_request [Boolean] is the error to be displayed for a fetch or normal request.
  # @return [String, JSON] formatted error display.
  def send_appropriate_error_response(err, fetch_request)
    fetch_request ? show_json_error(err) : show_page_error(err)
  end

  # Route the permission error-display for page/fetch calls.
  #
  # @param fetch_request [Boolean] is the error to be displayed for a fetch or normal request.
  # @return [String, JSON] formatted permission error display.
  def show_auth_error(fetch_request)
    fetch_request ? show_json_permission_error : show_unauthorised
  end

  # Show a permission-refused page.
  #
  # @return [String] the HTML containing an error message.
  def show_unauthorised
    response.status = 403
    view(inline: "<div class='crossbeams-warning-note'><strong>Warning</strong><br>You do not have permission for this task</div>", layout: appropriate_layout)
  end

  # Route the task not permitted error-display for page/fetch calls.
  #
  # @param fetch_request [Boolean] is the error to be displayed for a fetch or normal request.
  # @param err [Exception] The raised exception
  # @return [String, JSON] formatted task not permitted error display.
  def show_task_not_permitted_error(fetch_request, err)
    fetch_request ? show_json_task_not_permitted_error(err) : show_task_not_permitted(err)
  end

  # Show a permission-refused page.
  #
  # @param err [Exception] The raised exception
  # @return [String] the HTML containing an error message.
  def show_task_not_permitted(err)
    response.status = 403
    view(inline: "<div class='crossbeams-warning-note'><strong>Task is not permitted</strong><br>#{err.message || 'The task may be performed at this time.'}</div>", layout: appropriate_layout)
  end

  # Show an informational message page.
  #
  # @param message [String] the information messge.
  # @return [String] the HTML containing the message.
  def show_page_info(message)
    view(inline: "<div class='crossbeams-info-note'><p><strong>Note:</strong></p><p>#{message}</p></div>", layout: appropriate_layout)
  end

  # Show a warning message page.
  #
  # @param message [String] the warning messge.
  # @return [String] the HTML containing the message.
  def show_page_warning(message)
    view(inline: "<div class='crossbeams-warning-note'><p><strong>Warning:</strong></p><p>#{message}</p></div>", layout: appropriate_layout)
  end

  # Show a success message page.
  #
  # @param message [String] the messge.
  # @return [String] the HTML containing the message.
  def show_page_success(message)
    view(inline: "<div class='crossbeams-success-note'><p><strong>Success:</strong></p><p>#{message}</p></div>", layout: appropriate_layout)
  end

  # Show an error message page. Also logs the error.
  #
  # @param err [Exception, String] the exception or error message.
  # @return [String] the HTML containing the message.
  def show_page_error(err)
    message = err.respond_to?(:message) ? err.message : err.to_s
    puts err.full_message if err.respond_to?(:full_message) # Log the error too
    view(inline: "<div class='crossbeams-error-note'><p><strong>Error</strong></p><p>#{message}</p></div>", layout: appropriate_layout)
  end

  # Show a message as a notice in JSON.
  #
  # @param message [String] the notice.
  # @return [JSON] the message formatted for javascript to handle.
  def show_json_notice(message)
    { flash: { notice: message } }.to_json
  end

  # Show a permission-refused message in JSON.
  #
  # @return [JSON] the message formatted for javascript to handle.
  def show_json_permission_error
    response.status = 403
    { flash: { error: 'You do not have permission for this task', type: 'permission' } }.to_json
  end

  # Show a task-not-permitted message in JSON.
  #
  # @param err [Exception] The raised exception
  # @return [JSON] the message formatted for javascript to handle.
  def show_json_task_not_permitted_error(err)
    response.status = 403
    { flash: { error: "Task is not permitted - #{err.message || 'The task may be performed at this time.'}", type: 'permission' } }.to_json
  end

  # Show an error message in JSON.
  #
  # @param message [Exception, String] the exception or error message.
  # @param status [Integer] the status to return - defaults to 500.
  # @return [JSON] the exception formatted for javascript to handle.
  def show_json_error(err, status: 500)
    msg = err.respond_to?(:message) ? err.message : err.to_s
    response.status = status
    if err.respond_to?(:backtrace)
      { exception: err.class.name, flash: { error: "An error occurred: #{msg}" }, backtrace: err.backtrace }.to_json
    else
      { exception: err.class.name, flash: { error: "An error occurred: #{msg}" } }.to_json
    end
  end

  # Show an error message in JSON with a 200 OK response.
  #
  # @param err [Exception, String] the exception or error message.
  # @return [JSON] the exception formatted for javascript to handle.
  def show_json_exception(err)
    show_json_error(err, status: 200)
  end

  # Format a Postgresql foreign key violation for the user.
  #
  # @param err [Exception] the exception.
  # @return [String] an explanation of the foreign key dependency.
  def pg_foreign_key_violation_msg(err)
    msg, det = err.message.delete("\n").split('DETAIL:')
    details = ENV['RACK_ENV'] == 'development' ? "Details: #{det.strip}" : ''
    table = msg.split('"')[1]
    foreign_table = msg.split('"').last
    "A \"#{foreign_table}\" record depends on this \"#{table}\" record. #{details}"
  end

  def appropriate_layout
    @registered_mobile_device ? 'layout_rmd' : 'layout'
  end
end
