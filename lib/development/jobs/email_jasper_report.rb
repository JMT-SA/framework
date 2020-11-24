# frozen_string_literal: true

module DevelopmentApp
  class EmailJasperReport < BaseQueJob
    def run(options = {})
      attachments = []
      options[:reports].each do |spec|
        attachments << build_report(options[:user_name], spec)
      end

      SendMailJob.enqueue(options[:email_settings].merge(notify_user: options[:user_name], attachments: attachments.map { |a| { path: a } }))
    end

    private

    def build_report(user, spec) # rubocop:disable Metrics/AbcSize
      jasper_params = JasperParams.new(spec[:report_name],
                                       current_user.login_name,
                                       spec[:report_params])
      jasper_params.return_full_path = true
      jasper_params.file_name = spec[:file] if spec[:file]
      jasper_params.mode = spec[:mode] if spec[:mode]
      jasper_params.parent_folder = spec[:parent_folder] if spec[:parent_folder]
      res = CreateJasperReport.call(jasper_params)

      unless res.success
        send_bus_message("Failed to build report '#{spec[:report_name]}' - #{res.message}",
                         message_type: :error,
                         target_user: user)
        raise "Failed to build report '#{spec[:report_name]}' - #{res.message}"
      end

      res.instance
    end
  end
end
