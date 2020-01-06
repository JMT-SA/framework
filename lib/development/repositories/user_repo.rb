# frozen_string_literal: true

module DevelopmentApp
  class UserRepo < BaseRepo
    build_for_select :users,
                     label: :user_name,
                     value: :id,
                     order_by: :user_name
    crud_calls_for :users, name: :user, wrapper: User
    build_for_select :user_email_groups,
                     label: :mail_group,
                     value: :id,
                     order_by: :mail_group
    build_inactive_select :user_email_groups,
                          label: :mail_group,
                          value: :id,
                          order_by: :mail_group

    crud_calls_for :user_email_groups, name: :user_email_group, wrapper: UserEmailGroup

    def update_user(id, attrs)
      new_attrs = attrs.to_h
      profile_present = new_attrs.keys.include?(:profile)
      new_attrs[:profile] = hash_for_jsonb_col(attrs[:profile]) if profile_present
      update(:users, id, new_attrs)
    end

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

    def link_users(id, user_ids)
      existing_ids      = DB[:user_email_groups_users].where(user_email_group_id: id).select_map(:user_id)
      old_ids           = existing_ids - user_ids
      new_ids           = user_ids - existing_ids

      DB[:user_email_groups_users].where(user_email_group_id: id).where(user_id: old_ids).delete
      new_ids.each do |user_id|
        DB[:user_email_groups_users].insert(user_email_group_id: id, user_id: user_id)
      end
    end

    def email_addresses(user_email_group: nil)
      if user_email_group.nil?
        email_addresses_for_all_users
      else
        user_email_group_id = DB[:user_email_groups].where(mail_group: user_email_group, active: true).get(:id)
        raise Crossbeams::FrameworkError, "Email group \"#{user_email_group}\" does not exist" if user_email_group_id.nil?

        email_addresses_for_group(user_email_group_id)
      end
    end

    def email_addresses_for_group(user_email_group_id)
      DB[:user_email_groups_users]
        .join(:users, id: :user_id)
        .select(:user_name, :email)
        .exclude(email: nil)
        .order(:user_name)
        .where(Sequel[:user_email_groups_users][:user_email_group_id] => user_email_group_id)
        .where(Sequel[:users][:active] => true)
        .map(%i[user_name email])
    end

    def email_addresses_for_all_users
      DB[:users].select(:user_name, :email).where(active: true).exclude(email: nil).order(:user_name).map(%i[user_name email])
    end
  end
end
