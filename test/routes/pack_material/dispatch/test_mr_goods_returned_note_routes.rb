# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMrGoodsReturnedNoteRoutes < RouteTester

  INTERACTOR = PackMaterialApp::MrGoodsReturnedNoteInteractor

  def test_edit
    authorise_pass! permission_check: PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNote
    ensure_exists!(INTERACTOR)
    PackMaterial::Dispatch::MrGoodsReturnedNote::Edit.stub(:call, bland_page) do
      get 'pack_material/dispatch/mr_goods_returned_notes/1/edit', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_edit_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/dispatch/mr_goods_returned_notes/1/edit', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_update
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:update_mr_goods_returned_note).returns(ok_response(instance: row_vals))
    patch_as_fetch 'pack_material/dispatch/mr_goods_returned_notes/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }

    url = '/pack_material/dispatch/mr_goods_returned_notes/1/edit'
    assert last_response.redirect?, "Expected last response to be redirect (status is #{last_response.status}, location is #{last_response.location}) - from: #{caller.first}"
    assert_equal url, last_response.location, "Expected redirect to '#{url}', was '#{last_response.location}' - from: #{caller.first}"
  end

  def test_update_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:update_mr_goods_returned_note).returns(bad_response)
    PackMaterial::Dispatch::MrGoodsReturnedNote::Edit.stub(:call, bland_page) do
      patch_as_fetch 'pack_material/dispatch/mr_goods_returned_notes/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog(has_error: true)
  end

  def test_delete
    authorise_pass! permission_check: PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNote
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_mr_goods_returned_note).returns(ok_response)
    delete_as_fetch 'pack_material/dispatch/mr_goods_returned_notes/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_delete_from_grid
  end

  def test_delete_fail
    authorise_pass! permission_check: PackMaterialApp::TaskPermissionCheck::MrGoodsReturnedNote
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:delete_mr_goods_returned_note).returns(bad_response)
    delete_as_fetch 'pack_material/dispatch/mr_goods_returned_notes/1', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_error
  end

  def test_new
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Dispatch::MrGoodsReturnedNote::New.stub(:call, bland_page) do
      get  'pack_material/dispatch/mr_goods_returned_notes/new', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_new_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/dispatch/mr_goods_returned_notes/new', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:create_mr_goods_returned_note).returns(ok_response(instance: row_vals))
    post_as_fetch 'pack_material/dispatch/mr_goods_returned_notes', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_json_add_to_grid(has_notice: true)
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_mr_goods_returned_note).returns(bad_response)
    PackMaterial::Dispatch::MrGoodsReturnedNote::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/dispatch/mr_goods_returned_notes', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end
  
  def test_create
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_mr_goods_returned_note).returns(ok_response)
    post 'pack_material/dispatch/mr_goods_returned_notes', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    expect_ok_redirect
  end
  
  def test_create_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_mr_goods_returned_note).returns(bad_response)
    PackMaterial::Dispatch::MrGoodsReturnedNote::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/dispatch/mr_goods_returned_notes', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_page
  
    PackMaterial::Dispatch::MrGoodsReturnedNote::New.stub(:call, bland_page) do
      post 'pack_material/dispatch/mr_goods_returned_notes', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_bad_redirect(url: '/pack_material/dispatch/mr_goods_returned_notes/new')
  end
end
