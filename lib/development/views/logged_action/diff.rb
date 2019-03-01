# frozen_string_literal: true

module Development
  module Logging
    module LoggedAction
      class Diff
        def self.call(id, left, right)
          ui_rule = UiRules::Compiler.new(:logged_action, :diff, id: id, left: left, right: right)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            if left.nil?
              page.add_notice 'There is no record of the changes that took place at this point', caption: 'Unable to show difference'
            else
              page.add_diff :logged_action
            end
          end

          layout
        end
      end
    end
  end
end
