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
      test_crud_calls_for :basic_pack_codes, name: :basic_pack_code, wrapper: BasicPackCode
      test_crud_calls_for :standard_pack_codes, name: :standard_pack_code, wrapper: StandardPackCode
      test_crud_calls_for :std_fruit_size_counts, name: :std_fruit_size_count, wrapper: StdFruitSizeCount
      test_crud_calls_for :fruit_actual_counts_for_packs, name: :fruit_actual_counts_for_pack, wrapper: FruitActualCountsForPack
      test_crud_calls_for :fruit_size_references, name: :fruit_size_reference, wrapper: FruitSizeReference
    end

    private

    def repo
      FruitSizeRepo.new
    end
  end
end
