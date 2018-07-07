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

    def update_user_permission(ids, security_group_id)
      upd = <<~SQL
        UPDATE programs_users
        SET security_group_id = #{security_group_id}
        WHERE id IN (#{ids.join(',')})
      SQL
      DB[upd].update
      qry = <<~SQL
        SELECT s.security_group_name,(SELECT string_agg(security_permission, '; ')
          FROM (SELECT sp.security_permission
                 FROM security_groups_security_permissions sgsp
                 JOIN security_permissions sp ON sp.id = sgsp.security_permission_id
                 WHERE sgsp.security_group_id = s.id) sub) AS permissions
        FROM security_groups s
        WHERE s.id = #{security_group_id}
      SQL
      success_response('Applied', DB[qry].first)
    end
  end
end
