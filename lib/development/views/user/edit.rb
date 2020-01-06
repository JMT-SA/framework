# frozen_string_literal: true

module Development
  module Masterfiles
    module User
      class Edit
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:user, :edit, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/development/masterfiles/users/#{id}"
              form.remote!
              form.method :update
              form.add_field :login_name
              form.add_field :user_name
              form.add_field :email
              form.add_field :homepage_id
            end
          end

          layout
        end
      end
    end
  end
end
