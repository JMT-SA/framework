# frozen_string_literal: true

module Development
  module Masterfiles
    module User
      class ApplySecurityGroupToProgram
        def self.call(id, ids, form_values: nil, form_errors: nil)
          rules = {
            fields: {
              security_group_id: { renderer: :select, options: SecurityApp::SecurityGroupRepo.new.for_select_security_groups, prompt: true },
              list: { renderer: :hidden }
            }, name: 'permission'
          }
          form_object = { list: ids.join(','), security_group_id: nil } # Set default...

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/development/masterfiles/users/set_permissions/#{id}"
              form.remote!
              form.method :update
              form.add_field :list
              form.add_field :security_group_id
            end
          end

          layout
        end
      end
    end
  end
end
