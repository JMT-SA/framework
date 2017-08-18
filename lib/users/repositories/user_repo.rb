class UserRepo < RepoBase
  def initialize
    set_main_table :users
    set_wrapper User
  end
end
