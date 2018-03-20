require File.join(File.expand_path('./../../', __FILE__), 'test_helper_for_routes')

class TestSecurityRoutes < RouteTester
  def test_auth_fail
    authorise_fail!
    get 'security/functional_areas/functional_areas/new', {}, 'rack.session' => {user_id: 1}

    # refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_auth_pass
    get 'security/functional_areas/functional_areas/new', {}, 'rack.session' => {user_id: 1}

    assert last_response.ok?
    # assert_equal last_response.body, 'All responses are OK'
  end
end
