# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module LabelApp
  class TestPrinterRepo < MiniTestWithHooks
    def test_for_selects
      assert_respond_to repo, :for_select_mes_modules
    end

    def test_crud_calls
      test_crud_calls_for :mes_modules, name: :mes_module, wrapper: MesModule
    end

    private

    def repo
      PrinterRepo.new
    end
  end
end
