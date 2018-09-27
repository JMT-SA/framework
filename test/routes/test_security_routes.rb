# frozen_string_literal: true

require File.join(File.expand_path('./../', __dir__), 'test_helper_for_routes')

class TestSecurityRoutes < RouteTester

  INTERACTOR = SecurityApp::FunctionalAreaInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Security::FunctionalAreas::FunctionalArea::Edit.stub(:call, bland_page) do
      get 'security/functional_areas/functional_areas/2/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'security/functional_areas/functional_areas/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end
  #
  # def test_show
  #   Security::FunctionalAreas::FunctionalArea::Show.stub(:call, bland_page) do
  #     get 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1 }
  #   end
  #   assert last_response.ok?
  # end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Security::FunctionalAreas::FunctionalArea::New.stub(:call, bland_page) do
      get 'security/functional_areas/functional_areas/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'security/functional_areas/functional_areas/new', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_functional_area).returns(ok_response)
    delete 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect
  end

  def test_delete_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_functional_area).returns(bad_response)
    delete 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_bad_redirect
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:update_functional_area).returns(ok_response)
    patch_as_fetch 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_json_redirect
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:update_functional_area).returns(bad_response)
    Security::FunctionalAreas::FunctionalArea::Edit.stub(:call, bland_page) do
      patch_as_fetch 'security/functional_areas/functional_areas/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_functional_area).returns(ok_response)
    post 'security/functional_areas/functional_areas', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_functional_area).returns(ok_response)
    post_as_fetch 'security/functional_areas/functional_areas', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_json_redirect
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_functional_area).returns(bad_response)
    Security::FunctionalAreas::FunctionalArea::New.stub(:call, bland_page) do
      post_as_fetch 'security/functional_areas/functional_areas', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_page

    Security::FunctionalAreas::FunctionalArea::New.stub(:call, bland_page) do
      post 'security/functional_areas/functional_areas', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/security/functional_areas/functional_areas/new')
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_functional_area).returns(bad_response)
    Security::FunctionalAreas::FunctionalArea::New.stub(:call, bland_page) do
      post_as_fetch 'security/functional_areas/functional_areas', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end
end
