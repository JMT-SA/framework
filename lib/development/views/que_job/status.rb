# frozen_string_literal: true

module Development
  module Logging
    module QueJob
      class Status
        def self.call
          ui_rule = UiRules::Compiler.new(:que_job, :status)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.add_table(rules[:details], rules[:headers], alignment: rules[:alignment])
            page.form(&:view_only!)
          end

          layout
        end
      end
    end
  end
end
