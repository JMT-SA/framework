module UiRules
  class SecurityPermissions < Base
    def generate_rules
      @this_repo = SecurityPermissionRepo.new
      make_form_object

      set_common_fields common_fields

      set_show_fields if @mode == :show

      form_name 'security_permission'.freeze
    end

    def set_show_fields
      fields[:security_permission] = { renderer: :label }
    end

    def common_fields
      {
        security_permission: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(security_permission: nil)
    end
  end
end
