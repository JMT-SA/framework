# frozen_string_literal: true

require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module LabelApp
  class TestMesModuleInteractor < MiniTestWithHooks
    include MesModuleFactory

    def test_repo
      repo = interactor.send(:repo)
      assert repo.is_a?(LabelApp::PrinterRepo)
    end

    def test_mes_module
      LabelApp::PrinterRepo.any_instance.stubs(:find_mes_module).returns(fake_mes_module)
      entity = interactor.send(:mes_module, 1)
      assert entity.is_a?(MesModule)
    end

    def test_refresh_mes_module
      skip 'todo'
    end

    private

    def mes_module_attrs
      {
        id: 1,
        module_code: Faker::Lorem.unique.word,
        module_type: 'ABC',
        server_ip: '192.168.0.1',
        ip_address: '192.168.50.51',
        port: 1,
        alias: 'ABC',
        active: true
      }
    end

    def fake_mes_module(overrides = {})
      MesModule.new(mes_module_attrs.merge(overrides))
    end

    def interactor
      @interactor ||= MesModuleInteractor.new(current_user, {}, {}, {})
    end
  end
end
