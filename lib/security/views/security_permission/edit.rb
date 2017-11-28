module Security
  module FunctionalAreas
    module SecurityPermission
      class Edit
        def self.call(id, form_values = nil, form_errors = nil)
          ui_rule = UiRules::Compiler.new(:security_permission, :edit, id: id)
          rules   = ui_rule.compile

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object ui_rule.form_object
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action "/security/functional_areas/security_permissions/#{id}"
              form.remote!
              form.method :update
              form.add_field :security_permission
            end
          end

          layout
        end
      end
    end
  end
end
