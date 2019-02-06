# frozen_string_literal: true

module UiRules
  class UserEmailGroupRule < Base
    def generate_rules
      @repo = DevelopmentApp::UserRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'user_email_group'
    end

    def set_show_fields
      fields[:mail_group] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
    end

    def common_fields
      {
        mail_group: { renderer: :select, options: AppConst::USER_EMAIL_GROUPS, required: true }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @repo.find_user_email_group(@options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(mail_group: nil)
    end
  end
end
