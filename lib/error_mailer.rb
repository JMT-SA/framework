module ErrorMailer
  module_function

  # Send an email based on an exception object.
  #
  # @param error [exception] the exception object.
  # @param subject [string] optional, the email subject.
  # @param message [string] optional, extra context to be included with the execption details in the mail body.
  # @param job_context [hash] optional, a hash of key: value to be included in the mail body.
  # @return [void]
  def send_exception_email(error, subject: nil, message: nil, append_recipients: nil, job_context: {}) # rubocop:disable Metrics/AbcSize
    send_to = calculate_recipients(append_recipients)
    body = []
    body << message unless message.nil?
    body << "Job context:\n#{job_context.map { |k, v| "#{k.to_s.ljust(20)}: #{v}" }.join("\n")}\n" unless job_context.empty?

    body << "Time: #{Time.now}\n"
    body << error.message
    body << error.full_message
    body << 'CAUSE:' if error.cause
    body << error.cause.to_s if error.cause

    mail_opts = {
      to: send_to,
      subject: "[Error #{AppConst::ERROR_MAIL_PREFIX}] #{subject || error.message}",
      body: body.join("\n\n")
    }
    Que.enqueue mail_opts, job_class: 'DevelopmentApp::SendMailJob', queue: AppConst::QUEUE_NAME
  end

  # Send an error email with subject and message passed in describing an error condition..
  #
  # @param subject [string] optional, the email subject.
  # @param message [string] optional, the mail body.
  # @return [void]
  def send_error_email(subject: nil, message: nil, recipients: nil, append_recipients: nil)
    send_to = calculate_recipients(append_recipients, recipients: recipients)
    mail_opts = {
      to: send_to,
      subject: "[Error #{AppConst::ERROR_MAIL_PREFIX}] #{subject}",
      body: "Time: #{Time.now}\n#{message}"
    }
    Que.enqueue mail_opts, job_class: 'DevelopmentApp::SendMailJob', queue: AppConst::QUEUE_NAME
  end

  # This should be a private method, but as it is in a Module function, it cannot be private.
  def calculate_recipients(append_recipients, recipients: nil)
    send_to = if recipients
                recipients.is_a?(Array) ? recipients.map { |t, e| "#{t}<#{e}>" }.join(',') : recipients
              else
                AppConst::ERROR_MAIL_RECIPIENTS
              end
    return send_to unless append_recipients

    "#{send_to},#{append_recipients.is_a?(Array) ? append_recipients.map { |t, e| "#{t}<#{e}>" }.join(',') : append_recipients}"
  end
end
