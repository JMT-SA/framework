# frozen_string_literal: true

class UserRepo < RepoBase
  def initialize
    main_table :users
    table_wrapper User
    for_select_options label: :user_name,
                       value: :id,
                       order_by: :user_name
  end
end
