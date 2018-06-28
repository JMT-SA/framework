# frozen_string_literal: true

require File.join(File.expand_path('./../../../../', __FILE__), 'test_helper_for_routes')

class TestPartyRoutes < RouteTester
  # def around
  #   MasterfilesApp::OrganizationInteractor.any_instance.stubs(:exists?).returns(true)
  #   super
  # end

  def test_link_addresses
    authorise_pass!
    ensure_exists!(MasterfilesApp::PartyInteractor)
    MasterfilesApp::PartyInteractor.any_instance.stubs(:link_addresses).returns(ok_response)
    post 'masterfiles/parties/link_addresses/1', { selection: { list: '1,2,3' } }, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_redirect

    MasterfilesApp::PartyInteractor.any_instance.stubs(:link_addresses).returns(bad_response)
    post 'masterfiles/parties/link_addresses/1', { selection: { list: '1,2,3' } }, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    # expect_ok_redirect
    # TODO: test flash messages
  end

  def test_link_contact_methods
    authorise_pass!
    ensure_exists!(MasterfilesApp::PartyInteractor)
    MasterfilesApp::PartyInteractor.any_instance.stubs(:link_contact_methods).returns(ok_response)
    post 'masterfiles/parties/link_contact_methods/1', { selection: { list: '1,2,3' } }, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    expect_ok_redirect

    MasterfilesApp::PartyInteractor.any_instance.stubs(:link_contact_methods).returns(bad_response)
    post 'masterfiles/parties/link_contact_methods/1', { selection: { list: '1,2,3' } }, 'rack.session' => { user_id: 1, last_grid_url: '/' }
    # expect_ok_redirect
    # TODO: test flash messages
  end
end
