# frozen_string_literal: true

require File.join(File.expand_path('./../../../../', __FILE__), 'test_helper_for_routes')

class TestPartyRoutes < RouteTester
  # def around
  #   MasterfilesApp::OrganizationInteractor.any_instance.stubs(:exists?).returns(true)
  #   super
  # end

  def test_the_following_routes
    skip 'masterfiles/parties/organizations/addresses'
    skip 'masterfiles/parties/organizations/contact_methods'
    skip 'masterfiles/parties/people/addresses'
    skip 'masterfiles/parties/people/contact_methods'
    skip 'masterfiles/parties/link_addresses'
    skip 'masterfiles/parties/link_contact_methods'
  end
end
