# frozen_string_literal: true

# rubocop#:disable Metrics/ClassLength
# rubocop:disable Metrics/AbcSize

module UiRules
  class UserRule < Base
    def generate_rules
      @repo = DevelopmentApp::UserRepo.new
      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_new_fields if @mode == :new
      set_edit_fields if @mode == :edit
      set_detail_fields if @mode == :details
      set_password_fields if @mode == :change_password

      form_name 'user'
    end

    def set_new_fields
      fields[:password] = { subtype: :password }
      fields[:password_confirmation] = { subtype: :password, caption: 'Confirm password' }
    end

    def set_detail_fields
      fields[:old_password] = { subtype: :password }
      set_show_fields
      set_new_fields
    end

    def set_password_fields
      set_show_fields
      set_new_fields
    end

    def set_edit_fields
      fields[:login_name] = { renderer: :label }
    end

    def set_show_fields
      fields[:login_name] = { renderer: :label }
      fields[:user_name] = { renderer: :label }
      fields[:email] = { renderer: :label }
      fields[:active] = { renderer: :label, as_boolean: true }
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

      @form_object = if @mode == :details
                       OpenStruct.new(@repo.find_user(@options[:id]).to_h.merge(password: nil,
                                                                                old_password: nil,
                                                                                password_confirmation: nil))
                     elsif @mode == :change_password
                       OpenStruct.new(@repo.find_user(@options[:id]).to_h.merge(password: nil,
                                                                                password_confirmation: nil))
                     else
                       @repo.find_user(@options[:id])
                     end
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
# rubocop#:enable Metrics/ClassLength
# rubocop:enable Metrics/AbcSize
