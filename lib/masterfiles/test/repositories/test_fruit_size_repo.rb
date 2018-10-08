# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestFruitSizeRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_basic_pack_codes
      assert_respond_to repo, :for_select_standard_pack_codes
      assert_respond_to repo, :for_select_std_fruit_size_counts
      assert_respond_to repo, :for_select_fruit_actual_counts_for_packs
      assert_respond_to repo, :for_select_fruit_size_references
    end

    def test_crud_calls
      assert_respond_to repo, :find_basic_pack_code
      assert_respond_to repo, :create_basic_pack_code
      assert_respond_to repo, :update_basic_pack_code
      assert_respond_to repo, :delete_basic_pack_code

      assert_respond_to repo, :find_standard_pack_code
      assert_respond_to repo, :create_standard_pack_code
      assert_respond_to repo, :update_standard_pack_code
      assert_respond_to repo, :delete_standard_pack_code

      assert_respond_to repo, :find_std_fruit_size_count
      assert_respond_to repo, :create_std_fruit_size_count
      assert_respond_to repo, :update_std_fruit_size_count
      assert_respond_to repo, :delete_std_fruit_size_count

      assert_respond_to repo, :find_fruit_actual_counts_for_pack
      assert_respond_to repo, :create_fruit_actual_counts_for_pack
      assert_respond_to repo, :update_fruit_actual_counts_for_pack
      assert_respond_to repo, :delete_fruit_actual_counts_for_pack

      assert_respond_to repo, :find_fruit_size_reference
      assert_respond_to repo, :create_fruit_size_reference
      assert_respond_to repo, :update_fruit_size_reference
      assert_respond_to repo, :delete_fruit_size_reference
    end

    private

    def repo
      FruitSizeRepo.new
    end
  end
end
