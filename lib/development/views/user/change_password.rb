# frozen_string_literal: true

module Development
  module Masterfiles
    module User
      class ChangePassword
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:user, :change_password, id: id, form_values: form_values, form_errors: form_errors)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/development/masterfiles/users/#{id}/change_password"
              form.remote!
              form.method :update
              form.add_field :login_name
              form.add_field :user_name
              form.add_field :email
              form.add_text 'Change password', wrapper: :b
              form.add_field :password
              form.add_field :password_confirmation
            end
          end

          layout
        end
      end
    end
  end
end
