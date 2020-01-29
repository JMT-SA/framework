# frozen_string_literal: true

module UiRules
  class UserRule < Base
    def generate_rules # rubocop:disable Metrics/AbcSize, Metrics/PerceivedComplexity , Metrics/CyclomaticComplexity
      @repo = DevelopmentApp::UserRepo.new
      build_permission_tree if @mode == :permission_tree

      make_form_object
      apply_form_values

      common_values_for_fields common_fields

      set_show_fields if @mode == :show
      set_new_fields if @mode == :new
      set_edit_fields if @mode == :edit
      set_detail_fields if @mode == :details
      set_password_fields if @mode == :change_password
      set_permission_tree_fields if @mode == :permission_tree

      form_name 'user'
    end

    def build_permission_tree
      ptree = Crossbeams::Config::UserPermissions.new(@repo.find_user(@options[:id]))
      @tree_fields = ptree.fields
      rules[:tree_fields] = ptree.grouped_fields
    end

    def set_new_fields
      fields[:password] = { subtype: :password }
      fields[:password_confirmation] = { subtype: :password, caption: 'Confirm password' }
    end

    def set_detail_fields
      rules[:can_change_password] = Crossbeams::Config::UserPermissions.can_user?(@form_object, :password, :can_be_changed_by_user)
      fields[:old_password] = { subtype: :password }
      set_show_fields
      set_new_fields
    end

    def set_password_fields
      set_show_fields
      set_new_fields
    end

    def set_permission_tree_fields
      fields[:user_name] = { renderer: :label }
      @tree_fields.each do |tf|
        fields[tf[:field]] = { renderer: :checkbox, caption: make_caption(tf[:field]), tooltip: tf[:description] } # Make this tooltip...
      end
    end

    def set_edit_fields
      menu_options = SecurityApp::MenuRepo.new.for_select_homepages
      fields[:login_name] = { renderer: :label }
      fields[:homepage_id] = { renderer: :select, parent_field: :profile, options: menu_options, prompt: true }
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

    def make_form_object # rubocop:disable Metrics/AbcSize
      make_new_form_object && return if @mode == :new

      @form_object = if @mode == :details
                       OpenStruct.new(@repo.find_user(@options[:id]).to_h.merge(password: nil,
                                                                                old_password: nil,
                                                                                password_confirmation: nil))
                     elsif @mode == :change_password
                       OpenStruct.new(@repo.find_user(@options[:id]).to_h.merge(password: nil,
                                                                                password_confirmation: nil))
                     elsif @mode == :permission_tree
                       perms = {}
                       @tree_fields.each { |tree| perms[tree[:field]] = tree[:value] }
                       OpenStruct.new(@repo.find_user(@options[:id]).to_h.merge(perms))
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
