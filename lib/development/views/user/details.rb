# frozen_string_literal: true

module Development
  module Masterfiles
    module User
      class Details
        def self.call(id, form_values: nil, form_errors: nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:user, :details, id: id, form_values: form_values, form_errors: form_errors)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/development/masterfiles/users/#{id}/details"
              form.remote!
              form.method :update
              form.add_field :login_name
              form.add_field :user_name
              form.add_field :email
              if rules[:can_change_password]
                form.add_text 'Change password', wrapper: :b
                form.add_field :old_password
                form.add_field :password
                form.add_field :password_confirmation
              else
                form.view_only!
              end
            end
          end

          layout
        end
      end
    end
  end
end
