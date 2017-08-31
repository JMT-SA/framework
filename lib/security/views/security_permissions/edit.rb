module Security
  module FunctionalAreas
    module SecurityPermissions
      class Edit
        def self.call(id, form_values = nil, form_errors = nil)
          this_repo = SecurityPermissionRepo.new
          obj       = this_repo.find(id)
          rules     = {
            fields: {
              security_permission: {}
            }
          }

          layout = Crossbeams::Layout::Page.build(rules) do |page|
            page.form_object obj
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
