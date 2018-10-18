# frozen_string_literal: true

module Development
  module Masterfiles
    module User
      class New
        def self.call(form_values: nil, form_errors: nil, remote: true) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:user, :new, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/development/masterfiles/users'
              form.remote! if remote
              form.add_field :login_name
              form.add_field :user_name
              form.add_field :password
              form.add_field :password_confirmation
              form.add_field :email
            end
          end

          layout
        end
      end
    end
  end
end
