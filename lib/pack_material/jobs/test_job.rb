# frozen_string_literal: true

module PackMaterialApp
  class TestJob < BaseQueJob
    def run(user_id, time:)
      repo = DevelopmentApp::UserRepo.new
      user = repo.find_user(user_id)

      repo.transaction do
        File.open('atest.txt', 'a') do |f|
          f << "\nUser: #{user.login_name} : #{time}"
        end
        finish
      end
    end
  end
end
