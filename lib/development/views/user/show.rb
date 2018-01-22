# frozen_string_literal: true

module Development
  module Masterfiles
    module User
      class Show
        def self.call(id)
          ui_rule = UiRules::Compiler.new(:user, :show, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form do |form|
              form.view_only!
              form.add_field :login_name
              form.add_field :user_name
              form.add_field :email
              form.add_field :active
            end
          end

          layout
        end
      end
    end
  end
end
