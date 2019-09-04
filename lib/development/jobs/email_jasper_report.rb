# frozen_string_literal: true

module DevelopmentApp
  class EmailJasperReport < BaseQueJob
    def run(options = {})
      attachments = []
      options[:reports].each do |spec|
        attachments << build_report(options[:user_name], spec)
      end

      SendMailJob.enqueue(options[:email_settings].merge(attachments: attachments.map { |a| { path: a } }))
    end

    private

    def build_report(user, spec)
      res = CreateJasperReport.call(report_name: spec[:report_name],
                                    user: user,
                                    file: spec[:file],
                                    params: spec[:report_params].merge(return_full_path: true))
      raise "Failed to build report '#{spec[:report_name]}' - #{res.message}" unless res.success

      res.instance
    end
  end
end
