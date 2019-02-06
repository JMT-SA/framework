# frozen_string_literal: true

module Development
  module Masterfiles
    module UserEmailGroup
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:user_email_group, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              # form.caption 'User Email Group'
              form.view_only!
              form.add_field :mail_group
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
