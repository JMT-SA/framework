module UiRules
  class SecurityGroups < Base
    def generate_rules
      @this_repo = SecurityGroupRepo.new
      make_form_object

      set_common_fields common_fields

      set_permission_fields if @mode == :permissions
      set_show_fields if @mode == :show

      form_name 'security_group'.freeze
    end

    def set_permission_fields
      perm_repo = SecurityPermissionRepo.new
      fields[:security_permissions] = { renderer: :multi, options: perm_repo.for_select, selected: @form_object.security_permissions.map(&:id) }
      fields[:security_group_name]  = { renderer: :label }
    end

    def set_show_fields
      fields[:security_group_name]  = { renderer: :label }
    end

    def common_fields
      {
        security_group_name: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new
      make_permission_form_object && return if @mode == :permissions

      @form_object = @this_repo.find(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(security_group_name: nil)
    end

    def make_permission_form_object
      @form_object = @this_repo.find_with_permissions(@options[:id])
    end
  end
end
