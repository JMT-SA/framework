require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

module MasterfilesApp
  class TestPartyInteractor < Minitest::Test
    def test_link_addresses
      PartyRepo.any_instance.stubs(:link_addresses).returns(true)
      x = interactor.link_addresses(1, [1, 2, 3])
      expected = interactor.success_response('Addresses linked successfully')
      assert_equal(expected, x)
    end

    def test_link_contact_methods
      PartyRepo.any_instance.stubs(:link_contact_methods).returns(true)
      x = interactor.link_contact_methods(1, [1, 2, 3])
      expected = interactor.success_response('Contact methods linked successfully')
      assert_equal(expected, x)
    end

    private

    def interactor
      @interactor ||= PartyInteractor.new(current_user, {}, {}, {})
    end
  end
end
