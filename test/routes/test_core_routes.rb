require File.join(File.expand_path('./../../', __FILE__), 'test_helper_for_routes')

class TestCoreRoutes < RouteTester

  def test_root_before_login
    get '/'

    assert last_response.redirect?
    follow_redirect!
    assert last_response.ok?
    assert last_response.body.include?('Login')
  end

  def test_root_after_login
    get '/', {}, 'rack.session' => { user_id: 1 }

    assert last_response.ok?
    assert last_response.body.include?('Kromco')
  end

  # ROUTES
  # >> Rodauth...
  # developer_documentation
  # iframe
  # logout
  # versions
  # not_found
  # list
  #  :id
  #    with_params
  #    multi
  #    grid
  #    grid_multi
  #    nested_grid
  # print_grid
  # search
  #   :id
  #     run
  #     grid
  #     xls
end

