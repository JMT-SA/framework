# frozen_string_literal: true

class UserRepo < RepoBase
  build_for_select :users,
                   label: :user_name,
                   value: :id,
                   order_by: :user_name
end
