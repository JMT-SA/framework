# frozen_string_literal: true

module Development
  module Statuses
    module Status
      class Select
        def self.call
          ui_rule = UiRules::Compiler.new(:status, :select)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.action '/development/statuses/show'
              form.add_field :table_name
              form.add_field :row_data_id
            end
          end

          layout
        end
      end
    end
  end
end
