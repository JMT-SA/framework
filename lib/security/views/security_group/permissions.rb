module Security
  module FunctionalAreas
    module SecurityGroup
      class Permissions
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:security_group, :permissions, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/security/functional_areas/security_groups/#{id}/permissions"
              form.remote!
              form.add_field :security_group_name
              form.add_field :security_permissions
            end
          end

          layout
        end
      end
    end
  end
end
