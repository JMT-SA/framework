module ErrorMailer
  module_function

  # Send an email based on an exception object.
  #
  # @param error [exception] the exception object.
  # @param subject [string] optional, the email subject.
  # @param message [string] optional, extra context to be included with the execption details in the mail body.
  # @param job_context [hash] optional, a hash of key: value to be included in the mail body.
  # @return [void]
  def send_exception_email(error, subject: nil, message: nil, job_context: {}) # rubocop:disable Metrics/AbcSize
    body = []
    body << message unless message.nil?
    body << "Job context:\n#{job_context.map { |k, v| "#{k.to_s.ljust(20)}: #{v}" }.join("\n")}\n" unless job_context.empty?

    body << error.message
    body << error.full_message
    body << 'CAUSE:' if error.cause
    body << error.cause.to_s if error.cause

    mail_opts = {
      to: AppConst::ERROR_MAIL_RECIPIENTS,
      subject: "[Error #{AppConst::ERROR_MAIL_PREFIX}] #{subject || error.message}",
      body: body.join("\n\n")
    }
    DevelopmentApp::SendMailJob.enqueue(mail_opts)
  end

  # Send an error email with subject and message passed in.
  #
  # @param subject [string] optional, the email subject.
  # @param message [string] optional, the mail body.
  # @return [void]
  def send_error_email(subject: nil, message: nil)
    mail_opts = {
      to: AppConst::ERROR_MAIL_RECIPIENTS,
      subject: "[Error #{AppConst::ERROR_MAIL_PREFIX}] #{subject}",
      body: message
    }
    DevelopmentApp::SendMailJob.enqueue(mail_opts)
  end
end
