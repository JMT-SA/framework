# frozen_string_literal: true

module DevelopmentApp
  class UserRepo < BaseRepo
    build_for_select :users,
                     label: :user_name,
                     value: :id,
                     order_by: :user_name
    crud_calls_for :users, name: :user, wrapper: User

    def delete_or_deactivate_user(id)
      if SecurityApp::MenuRepo.new.existing_prog_ids_for_user(id).empty?
        delete_user(id)
        success_response('Deleted user')
      else
        deactivate(:users, id)
        success_response('De-activated user')
      end
    end

    def deactivate_user(id)
      deactivate(:users, id)
    end

    def save_new_password(id, password)
      password_hash = BCrypt::Password.create(password)
      upd = "UPDATE users SET password_hash = '#{password_hash}' WHERE id = #{id};"
      DB[upd].update
    end
  end
end
