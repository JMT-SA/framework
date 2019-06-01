# frozen_string_literal: true

module Development
  module Masterfiles
    module User
      class PermissionTree
        def self.call(id, user, form_values = nil, form_errors = nil) # rubocop:disable Metrics/AbcSize
          ui_rule = UiRules::Compiler.new(:user, :permission_tree, user: user, id: id, form_values: form_values)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/development/masterfiles/users/#{id}/permission_tree"
              form.remote!
              form.method :update
              form.add_field :user_name
              # Add an expend/collapse all ui control here
              rules[:tree_fields].each do |group, list|
                form.fold_up do |fold|
                  fold.caption group.to_s.split('_').map(&:capitalize).join(' ')
                  list.each do |permission|
                    fold.add_field permission[:field]
                  end
                end
              end
            end
          end

          layout
        end
      end
    end
  end
end
