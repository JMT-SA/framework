# frozen_string_literal: true

module UiRules
  class SecurityPermissionRule < Base
    def generate_rules
      @repo = SecurityApp::SecurityGroupRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'security_permission'
    end

    def set_show_fields
      fields[:security_permission] = { renderer: :label }
    end

    def common_fields
      {
        security_permission: { required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find(:security_permissions, SecurityApp::SecurityPermission, @options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(security_permission: nil)
    end
  end
end
