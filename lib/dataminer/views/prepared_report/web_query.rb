# frozen_string_literal: true

module Dataminer
  module Report
    module PreparedReport
      class WebQuery
        def self.call(instance, url) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:prepared_report, :webquery, instance: instance, url: url)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.remote!
              form.view_only!
              form.add_field :report_description
              form.add_text 'Prepared report was saved. Use this value as your web query url if you wish to run the report from Excel.'
              form.add_field :webquery_url
              form.add_field :id
            end
          end

          layout
        end
      end
    end
  end
end
