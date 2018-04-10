# frozen_string_literal: true

require File.join(File.expand_path('./../../', __FILE__), 'test_helper_for_routes')

class TestLoggingRoutes < RouteTester
  def around
    DevelopmentApp::LoggingInteractor.any_instance.stubs(:exists?).returns(true)
    super
  end

  def test_show
    Development::Logging::LoggedAction::Show.stub(:call, bland_page) do
      get 'development/logging/logged_actions/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    get 'development/logging/logged_actions/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_show_grid
    skip 'todo: ensure grid url is called from show...'
  end
end
