# frozen_string_literal: true

module CommonHelperMethods
  def current_user
    DevelopmentApp::User.new(
      id: 1,
      login_name: 'usr_login',
      user_name: 'User Name',
      password_hash: '$2a$10$wZQEHY77JEp93JgUUyVqgOkwhPb8bYZLswD5NVTWOKwU1ssQTYa.K',
      email: 'current_user@example.com',
      active: true
    )
  end
end