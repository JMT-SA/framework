# frozen_string_literal: true

module DM
  module Report
    module PreparedReport
      class Properties
        def self.call(instance, url, remote = true)
          ui_rule = UiRules::Compiler.new(:prepared_report, :properties, instance: instance, url: url)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.remote! if remote
              form.view_only!
              form.no_submit! unless remote
              form.add_field :report_description
              form.add_text 'Use this value as your web query url if you wish to run the report from Excel:'
              form.add_field :webquery_url
              form.add_field :id
              form.add_field :param_description
            end
          end

          layout
        end
      end
    end
  end
end
