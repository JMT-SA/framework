# frozen_string_literal: true

module UiRules
  class UserRule < Base
    def generate_rules
      @this_repo = UserRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_new_fields if @mode == :new
      set_edit_fields if @mode == :edit

      form_name 'user'
    end

    def set_new_fields
      fields[:password] = { subtype: :password }
      fields[:password_confirmation] = { subtype: :password, caption: 'Confirm Password' }
    end

    def set_edit_fields
      fields[:login_name] = { renderer: :label }
    end

    def set_show_fields
      fields[:login_name] = { renderer: :label }
      fields[:user_name] = { renderer: :label }
      fields[:email] = { renderer: :label }
      fields[:active] = { renderer: :label }
    end

    def common_fields
      {
        login_name: {},
        user_name: {},
        email: {}
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(:users, User, @options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(login_name: nil,
                                    user_name: nil,
                                    password: nil,
                                    password_confirmation: nil,
                                    email: nil,
                                    active: true)
    end
  end
end
