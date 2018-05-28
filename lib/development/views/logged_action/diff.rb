# frozen_string_literal: true

module Development
  module Logging
    module LoggedAction
      class Diff
        def self.call(id, left, right)
          ui_rule = UiRules::Compiler.new(:logged_action, :diff, id: id, left: left, right: right)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.add_diff :logged_action
            # page.callback_section do |section| # does not work: inline script is not fired in dialog...
            #   section.caption = 'Test'
            #   section.url = '/security/security_groups/2'
            # end
          end

          layout
        end
      end
    end
  end
end
