# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMarketingVarietyRoutes < RouteTester

  INTERACTOR = MasterfilesApp::CultivarInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Masterfiles::Fruit::MarketingVariety::Edit.stub(:call, bland_page) do
      get 'masterfiles/fruit/marketing_varieties/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/fruit/marketing_varieties/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Masterfiles::Fruit::MarketingVariety::Show.stub(:call, bland_page) do
      get 'masterfiles/fruit/marketing_varieties/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/fruit/marketing_varieties/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:update_marketing_variety).returns(ok_response(instance: row_vals))
    patch_as_fetch 'masterfiles/fruit/marketing_varieties/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:update_marketing_variety).returns(bad_response)
    Masterfiles::Fruit::MarketingVariety::Edit.stub(:call, bland_page) do
      patch_as_fetch 'masterfiles/fruit/marketing_varieties/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_link_marketing_varieties
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:link_marketing_varieties).returns(ok_response)
    post '/masterfiles/fruit/cultivars/1/link_marketing_varieties', { selection: { list: '1,2,3' } }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    assert last_response.redirect?
    expect_ok_redirect

    INTERACTOR.any_instance.stubs(:link_marketing_varieties).returns(ok_response(message: 'notice message'))
    post '/masterfiles/fruit/cultivars/1/link_marketing_varieties', { selection: { list: '1,2,3' } }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_flash_notice('notice message')
    INTERACTOR.any_instance.stubs(:link_marketing_varieties).returns(bad_response(message: 'error message'))
    post '/masterfiles/fruit/cultivars/1/link_marketing_varieties', { selection: { list: '1,2,3' } }, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_flash_error('error message')
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Masterfiles::Fruit::MarketingVariety::New.stub(:call, bland_page) do
      get  'masterfiles/fruit/cultivars/1/marketing_varieties/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'masterfiles/fruit/cultivars/1/marketing_varieties/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_marketing_variety).returns(ok_response)
    post 'masterfiles/fruit/cultivars/1/marketing_varieties', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_marketing_variety).returns(ok_response)
    post_as_fetch 'masterfiles/fruit/cultivars/1/marketing_varieties', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_json_redirect
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_marketing_variety).returns(bad_response)
    Masterfiles::Fruit::MarketingVariety::New.stub(:call, bland_page) do
      post 'masterfiles/fruit/cultivars/1/marketing_varieties', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/masterfiles/fruit/cultivars/1/marketing_varieties/new')
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_marketing_variety).returns(bad_response)
    Masterfiles::Fruit::MarketingVariety::New.stub(:call, bland_page) do
      post_as_fetch 'masterfiles/fruit/cultivars/1/marketing_varieties', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end
end
