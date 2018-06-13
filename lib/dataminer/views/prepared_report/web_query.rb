# frozen_string_literal: true

module DM
  module Report
    module PreparedReport
      class WebQuery
        def self.call(instance, url, remote = true)
          ui_rule = UiRules::Compiler.new(:prepared_report, :webquery, instance: instance, url: url)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.remote! if remote
              form.view_only!
              form.no_submit! unless remote
              form.add_field :webquery_url
              form.add_text 'Click on the button above to copy this link to the clipboard.'
            end
          end

          layout
        end
      end
    end
  end
end
