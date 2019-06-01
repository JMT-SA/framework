# frozen_string_literal: true

module Development
  module Masterfiles
    module UserEmailGroup
      class Edit
        def self.call(id, form_values: nil, form_errors: nil)
          ui_rule = UiRules::Compiler.new(:user_email_group, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.caption 'Edit User Email Group'
              form.action "/development/masterfiles/user_email_groups/#{id}"
              form.remote!
              form.method :update
              form.add_field :mail_group
            end
          end

          layout
        end
      end
    end
  end
end
