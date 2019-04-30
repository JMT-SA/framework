require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestBaseInteractor < Minitest::Test

  def interactor
    BaseInteractor.new(current_user, {}, {}, {})
  end

  def test_exists?
    BaseRepo.any_instance.expects(:exists?).returns(true)
    interactor.exists?(:users, 1)
  end

  def test_validation_failed_response
    results = OpenStruct.new(messages: { roles: ['You did not choose a role'] })
    x = interactor.validation_failed_response(results)
    expected = OpenStruct.new( success: false,
                               instance: {},
                               errors: results.messages,
                               message: 'Validation error')
    assert_equal expected, x
  end

  def test_validation_failed_response_with_instance
    results = OpenStruct.new(messages: { roles: ['You did not choose a role'] }, id: 1, name: 'fred')
    x = interactor.validation_failed_response(results)
    expected = OpenStruct.new( success: false,
                               instance: {id: 1, name: 'fred'},
                               errors: results.messages,
                               message: 'Validation error')
    assert_equal expected, x
  end

  def test_failed_response
    mes = 'Failed'
    x = interactor.failed_response(mes, current_user)
    expected = OpenStruct.new( success: false,
                               instance: current_user,
                               errors: {},
                               message: mes)
    assert_equal expected, x
  end

  def test_success_response
    mes = 'Success'
    x = interactor.success_response(mes, current_user)
    expected = OpenStruct.new( success: true,
                               instance: current_user,
                               errors: {},
                               message: mes)
    assert_equal expected, x
  end

  def test_unwrap_extended_columns_params
    [
      { p: {}, ep: {}, ee: {} },
      { p: { a: 1 }, ep: { a: 1 }, ee: {} },
      { p: { a: 1, extcol_a: 2 }, ep: { a: 1 }, ee: { a: 2 } },
      { p: { extcol_a: 2 }, ep: {}, ee: { a: 2 } }
    ].each do |set|
      params, expected_parms, expected_ext = set[:p], set[:ep], set[:ee]
      parms, ext = interactor.unwrap_extended_columns_params(params)
      assert_equal expected_parms, parms
      assert_equal expected_ext, ext
    end
  end

  def test_select_exended
    [
      { p: {}, ep: {} },
      { p: { a: 1 }, ep: {} },
      { p: { a: 1, extcol_a: 2 }, ep: { a: 2 } },
      { p: { extcol_a: 2 }, ep: { a: 2 } }
    ].each do |set|
      params, expected = set[:p], set[:ep]
      ext = interactor.select_extended_columns_params(params)
      assert_equal expected, ext
    end
  end

  def test_select_exended_with_prefix
    [
      { p: {}, ep: {} },
      { p: { a: 1 }, ep: {} },
      { p: { a: 1, extcol_a: 2 }, ep: { extcol_a: 2 } },
      { p: { extcol_a: 2 }, ep: { extcol_a: 2 } }
    ].each do |set|
      params, expected = set[:p], set[:ep]
      ext = interactor.select_extended_columns_params(params, delete_prefix: false)
      assert_equal expected, ext
    end
  end

  def test_add_extended_columns_to_changeset
    [
      [{}, {}, { extended_columns: {} }],
      [{ a: 1 }, {}, { a: 1, extended_columns: {} }],
      [{ a: 1 }, { b: 2 }, { a: 1, extended_columns: { b: 2 } }]
    ].each do |set, ext, expected|
      new_set = interactor.add_extended_columns_to_changeset(set, BaseRepo.new, ext)
      assert_equal expected, new_set
    end
  end

  def test_extended_columns_for_row
    [
      [{}, {}],
      [{ a: 1 }, {}],
      [{ a: 1, extended_columns: { b: 2, c: 3 } }, { b: 2, c: 3 }]
    ].each do |instance, expected|
      res = interactor.extended_columns_for_row(instance)
      assert_equal expected, res
    end
  end
end
