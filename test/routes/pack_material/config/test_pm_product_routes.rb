# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestPmProductRoutes < RouteTester

  INTERACTOR = PackMaterialApp::PmProductInteractor

  def test_edit
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::PmProduct::Edit.stub(:call, bland_page) do
      get 'pack_material/config/pack_material_products/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/pack_material_products/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_show
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::PmProduct::Show.stub(:call, bland_page) do
      get 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_show_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:update_pm_product).returns(ok_response(instance: row_vals))
    patch 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_update_grid
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:update_pm_product).returns(bad_response)
    PackMaterial::Config::PmProduct::Edit.stub(:call, bland_page) do
      patch 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:delete_pm_product).returns(ok_response)
    delete 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end
  #
  # def test_delete_fail
  #   authorise_pass!
  #   ensure_exists!(INTERACTOR)
  #   PackMaterialApp::PmProductInteractor.any_instance.stubs(:delete_pm_product).returns(bad_response)
  #   delete 'pack_material/config/pack_material_products/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
  #   expect_bad_redirect
  # end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Config::PmProduct::New.stub(:call, bland_page) do
      get  'pack_material/config/pack_material_products/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/config/pack_material_products/new', {}, 'rack.session' => { user_id: 1 }
    refute last_response.ok?
    assert_match(/permission/i, last_response.body)
  end

  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:create_pm_product).returns(ok_response)
    post 'pack_material/config/pack_material_products', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:create_pm_product).returns(ok_response)
    post_as_fetch 'pack_material/config/pack_material_products', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_json_redirect
  end

  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:create_pm_product).returns(bad_response)
    PackMaterial::Config::PmProduct::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/pack_material_products', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_page

    PackMaterial::Config::PmProduct::New.stub(:call, bland_page) do
      post 'pack_material/config/pack_material_products', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/pack_material/config/pack_material_products/new')
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:create_pm_product).returns(bad_response)
    PackMaterial::Config::PmProduct::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/pack_material_products', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end

  # r.on 'clone', Integer do |id|
  #   r.post do        # CLONE
  #     res = interactor.clone_pm_product(params[:pm_product])
  #     if res.success
  #       flash[:notice] = res.message
  #       redirect_to_last_grid(r)
  #     else
  #       # content = show_partial { PackMaterial::Config::PmProduct::Clone.call(id, params[:pm_product], res.errors) }
  #       # update_dialog_content(content: content, error: res.message)
  #
  #       re_show_form(r, res, url: "/pack_material/config/pack_material_products/clone/#{id}") do
  #         PackMaterial::Config::PmProduct::Clone.call(id, params[:pm_product], res.errors)
  #       end
  #     end
  #   end
  # end
  # r.post do        # CREATE
  #   res = interactor.create_pm_product(params[:pm_product])
  #   if res.success
  #     flash[:notice] = res.message
  #     redirect_to_last_grid(r)
  #   else
  #     re_show_form(r, res, url: '/pack_material/config/pack_material_products/new') do
  #       PackMaterial::Config::PmProduct::New.call(form_values: params[:pm_product],
  #                                                 form_errors: res.errors,
  #                                                 remote: fetch?(r))
  #     end
  #   end
  # end
  #

  def test_clone
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:clone_pm_product).returns(ok_response)
    post 'pack_material/config/pack_material_products/clone/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect

    post_as_fetch 'pack_material/config/pack_material_products/clone/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_json_redirect
  end

  def test_clone_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterialApp::PmProductInteractor.any_instance.stubs(:clone_pm_product).returns(bad_response)
    PackMaterial::Config::PmProduct::Clone.stub(:call, bland_page) do
      post 'pack_material/config/pack_material_products/clone/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    # expect_bland_page
    # expect_bad_redirect(url: '/pack_material/config/pack_material_products/clone/1')
    assert last_response.redirect?
    assert_equal '/pack_material/config/pack_material_products/1/clone', header_location
    refute last_response.ok?
    # p last_response
    # p last_response.body
    #
    PackMaterial::Config::PmProduct::Clone.stub(:call, bland_page) do
      post_as_fetch 'pack_material/config/pack_material_products/clone/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end
end
