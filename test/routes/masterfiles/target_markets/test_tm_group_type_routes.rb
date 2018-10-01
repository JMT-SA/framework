# frozen_string_literal: true

require File.join(File.expand_path('./../../../../', __FILE__), 'test_helper_for_routes')
# require File.join(File.expand_path('./../../../../', __dir__), 'test_helper_for_routes')

class TestTmGroupTypeRoutes < RouteTester

  INTERACTOR = MasterfilesApp::TargetMarketInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Masterfiles::TargetMarkets::TmGroupType::Edit.stub(:call, bland_page) do
      get 'masterfiles/target_markets/target_market_group_types/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/target_markets/target_market_group_types/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Masterfiles::TargetMarkets::TmGroupType::Show.stub(:call, bland_page) do
      get 'masterfiles/target_markets/target_market_group_types/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/target_markets/target_market_group_types/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:update_tm_group_type).returns(ok_response(instance: row_vals))
    patch_as_fetch 'masterfiles/target_markets/target_market_group_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:update_tm_group_type).returns(bad_response)
    Masterfiles::TargetMarkets::TmGroupType::Edit.stub(:call, bland_page) do
      patch_as_fetch 'masterfiles/target_markets/target_market_group_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_tm_group_type).returns(ok_response)
    delete_as_fetch 'masterfiles/target_markets/target_market_group_types/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Masterfiles::TargetMarkets::TmGroupType::New.stub(:call, bland_page) do
      get  'masterfiles/target_markets/target_market_group_types/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/target_markets/target_market_group_types/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_tm_group_type).returns(ok_response)
    post 'masterfiles/target_markets/target_market_group_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_tm_group_type).returns(ok_response)
    post_as_fetch 'masterfiles/target_markets/target_market_group_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_json_redirect
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_tm_group_type).returns(bad_response)
    Masterfiles::TargetMarkets::TmGroupType::New.stub(:call, bland_page) do
      post 'masterfiles/target_markets/target_market_group_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/masterfiles/target_markets/target_market_group_types/new')
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_tm_group_type).returns(bad_response)
    Masterfiles::TargetMarkets::TmGroupType::New.stub(:call, bland_page) do
      post_as_fetch 'masterfiles/target_markets/target_market_group_types', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end
end
