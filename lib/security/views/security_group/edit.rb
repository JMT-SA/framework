module Security
  module FunctionalAreas
    module SecurityGroup
      class Edit
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:security_group, :edit, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/security/functional_areas/security_groups/#{id}"
              form.remote!
              form.method :update
              form.add_field :security_group_name
            end
            # page.add_grid('sec_perms', '/list/security_permissions/grid', caption: 'Perms')
          end

          layout
        end
      end
    end
  end
end
