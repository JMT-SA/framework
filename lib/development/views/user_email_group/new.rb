# frozen_string_literal: true

module Development
  module Masterfiles
    module UserEmailGroup
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true)
          ui_rule = UiRules::Compiler.new(:user_email_group, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'New User Email Group'
              form.action '/development/masterfiles/user_email_groups'
              form.remote! if remote
              form.add_field :mail_group
            end
          end

          layout
        end
      end
    end
  end
end
