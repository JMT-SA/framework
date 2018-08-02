module UiRules
  class SecurityGroupRule < Base
    def generate_rules
      @repo = SecurityApp::SecurityGroupRepo.new
      make_form_object

      common_values_for_fields common_fields

      set_permission_fields if @mode == :permissions
      set_show_fields if @mode == :show

      form_name 'security_group'.freeze
    end

    def set_permission_fields
      fields[:security_permissions] = { renderer: :multi, options: @repo.for_select_security_permissions, selected: @form_object.security_permissions.map(&:id) }
      fields[:security_group_name]  = { renderer: :label }
    end

    def set_show_fields
      fields[:security_group_name]  = { renderer: :label }
    end

    def common_fields
      {
        security_group_name: { required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new
      make_permission_form_object && return if @mode == :permissions

      @form_object = @repo.find_security_group(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(security_group_name: nil)
    end

    def make_permission_form_object
      @form_object = @repo.find_with_permissions(@options[:id])
    end
  end
end
