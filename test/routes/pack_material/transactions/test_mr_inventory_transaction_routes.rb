# frozen_string_literal: true

require File.join(File.expand_path('./../../../', __dir__), 'test_helper_for_routes')

class TestMrInventoryTransactionRoutes < RouteTester

  INTERACTOR = PackMaterialApp::MrInventoryTransactionInteractor

  def test_add
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Transactions::MrInventoryTransaction::New.stub(:call, bland_page) do
      get  'pack_material/transactions/adhoc_stock_transactions/1/add', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_move
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Transactions::MrInventoryTransaction::New.stub(:call, bland_page) do
      get  'pack_material/transactions/adhoc_stock_transactions/1/move', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_remove
    authorise_pass!
    ensure_exists!(INTERACTOR)
    PackMaterial::Transactions::MrInventoryTransaction::New.stub(:call, bland_page) do
      get  'pack_material/transactions/adhoc_stock_transactions/1/remove', {}, 'rack.session' => { user_id: 1 }
    end
    expect_bland_page
  end

  def test_add_fail
    authorise_fail!
    ensure_exists!(INTERACTOR)
    get 'pack_material/transactions/adhoc_stock_transactions/1/add', {}, 'rack.session' => { user_id: 1 }
    expect_permission_error
  end

  def test_create_remotely
    authorise_pass!
    ensure_exists!(INTERACTOR)
    row_vals = Hash.new(1)
    INTERACTOR.any_instance.stubs(:create_adhoc_stock_transaction).returns(ok_response(instance: row_vals))
    post_as_fetch 'pack_material/transactions/adhoc_stock_transactions/1/', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    assert last_response.ok?
  end

  def test_create_remotely_fail
    authorise_pass!
    ensure_exists!(INTERACTOR)
    INTERACTOR.any_instance.stubs(:create_adhoc_stock_transaction).returns(bad_response)
    PackMaterial::Transactions::MrInventoryTransaction::New.stub(:call, bland_page) do
      post_as_fetch 'pack_material/transactions/adhoc_stock_transactions/1/', {}, 'rack.session' => { user_id: 1, last_grid_url: DEFAULT_LAST_GRID_URL }
    end
    expect_json_replace_dialog
  end
end
