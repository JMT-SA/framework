# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestRegisteredMobileDeviceRoutes < RouteTester

  INTERACTOR = SecurityApp::RegisteredMobileDeviceInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Security::Rmd::RegisteredMobileDevice::Edit.stub(:call, bland_page) do
      get 'security/rmd/registered_mobile_devices/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'security/rmd/registered_mobile_devices/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Security::Rmd::RegisteredMobileDevice::Show.stub(:call, bland_page) do
      get 'security/rmd/registered_mobile_devices/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'security/rmd/registered_mobile_devices/1', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:update_registered_mobile_device).returns(ok_response(instance: row_vals))
    patch_as_fetch 'security/rmd/registered_mobile_devices/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:update_registered_mobile_device).returns(bad_response)
    Security::Rmd::RegisteredMobileDevice::Edit.stub(:call, bland_page) do
      patch_as_fetch 'security/rmd/registered_mobile_devices/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_registered_mobile_device).returns(ok_response)
    delete_as_fetch 'security/rmd/registered_mobile_devices/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end

  def test_delete_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_registered_mobile_device).returns(bad_response)
    delete_as_fetch 'security/rmd/registered_mobile_devices/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_error
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    Security::Rmd::RegisteredMobileDevice::New.stub(:call, bland_page) do
      get  'security/rmd/registered_mobile_devices/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'security/rmd/registered_mobile_devices/new', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    instance = OpenStruct.new(id: 1, ip_address: '127.0.0.1', start_page_program_function_id: 1)
    INTERACTOR.any_instance.stubs(:create_registered_mobile_device).returns(ok_response(instance: instance))
    post_as_fetch 'security/rmd/registered_mobile_devices', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_add_to_grid
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_registered_mobile_device).returns(bad_response)
    Security::Rmd::RegisteredMobileDevice::New.stub(:call, bland_page) do
      post_as_fetch 'security/rmd/registered_mobile_devices', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_page

    Security::Rmd::RegisteredMobileDevice::New.stub(:call, bland_page) do
      post 'security/rmd/registered_mobile_devices', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/security/rmd/registered_mobile_devices/new')
  end
end
