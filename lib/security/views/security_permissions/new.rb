module Security
  module FunctionalAreas
    module SecurityPermissions
      class New
        def self.call(form_values = nil, form_errors = nil)
          rules = {
            fields: {
              security_permission: {}
            },
            name: 'security_permission'.freeze
          }

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object(OpenStruct.new(security_permission: nil))
            page.form_values form_values
            page.form_errors form_errors
            page.form do |form|
              form.action '/security/functional_areas/security_permissions'
              form.add_field :security_permission
            end
          end

          layout
        end
      end
    end
  end
end
