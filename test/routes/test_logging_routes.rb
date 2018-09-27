# frozen_string_literal: true

require File.join(File.expand_path('./../', __dir__), 'test_helper_for_routes')

class TestLoggingRoutes < RouteTester

  INTERACTOR = DevelopmentApp::LoggingInteractor

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Development::Logging::LoggedAction::Show.stub(:call, bland_page) do
      get 'development/logging/logged_actions/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'development/logging/logged_actions/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_show_grid
    expected =
      {
        columnDefs: {},
        rowDefs:    []
      }.to_json
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:logged_actions_grid).returns(expected)
    get_as_fetch 'development/logging/logged_actions/1/grid', {}, 'rack.session' => { user_id: 1 }
    assert_equal expected, last_response.body
  end
end
