# frozen_string_literal: true

module UiRules
  class User < Base
    def generate_rules
      @this_repo = UserRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show

      form_name 'user'
    end

    def set_show_fields
      fields[:login_name] = { renderer: :label }
      fields[:user_name] = { renderer: :label }
      fields[:password_hash] = { renderer: :label }
      fields[:email] = { renderer: :label }
      fields[:active] = { renderer: :label }
    end

    def common_fields
      {
        login_name: {},
        user_name: {},
        password_hash: {},
        email: {},
        active: { renderer: :checkbox }
      }
    end

    def make_form_object
      make_new_form_object && return if @mode == :new

      @form_object = @this_repo.find(:users, User, @options[:id])
    end

    def make_new_form_object
      @form_object = OpenStruct.new(login_name: nil,
                                    user_name: nil,
                                    password_hash: nil,
                                    email: nil,
                                    active: true)
    end
  end
end
