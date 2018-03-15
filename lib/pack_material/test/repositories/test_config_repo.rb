require File.join(File.expand_path('../../../../../test', __FILE__), 'test_helper')

module PackMaterialApp
  class TestConfigRepo < MiniTestWithHooks
    #
    # def before_all
    #   super
    #   10.times do |i|
    #     DB[:users].insert(
    #       login_name: "usr_#{i}",
    #       user_name: "User #{i}",
    #       password_hash: "$#{i}a$10$wZQEHY77JEp93JgUUyVqgOkwhPb8bYZLswD5NVTWOKwU1ssQTYa.K",
    #       email: "test_#{i}@example.com",
    #       active: true
    #     )
    #   end
    # end
    #
    # def after_all
    #   DB[:users].delete
    #   super
    # end

    def test_for_selects
      assert_respond_to repo, :for_select_domains
      assert_respond_to repo, :for_select_matres_types
      assert_respond_to repo, :for_select_matres_sub_types
    end

    def test_crud_calls
      assert_respond_to repo, :find_matres_type
      assert_respond_to repo, :create_matres_type
      assert_respond_to repo, :update_matres_type
      assert_respond_to repo, :delete_matres_type

      assert_respond_to repo, :find_matres_sub_type
      assert_respond_to repo, :create_matres_sub_type
      assert_respond_to repo, :update_matres_sub_type
      assert_respond_to repo, :delete_matres_sub_type

      assert_respond_to repo, :find_pm_product
      assert_respond_to repo, :create_pm_product
      assert_respond_to repo, :update_pm_product
      assert_respond_to repo, :delete_pm_product
    end

    def test_find_matres_type
      # assert_nil repo.find_matres_type(1)

      # DB[:material_resource_sub_types]
    end

    def repo
      ConfigRepo.new
    end
  end
end