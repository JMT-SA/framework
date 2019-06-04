# frozen_string_literal: true

require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestUserPemissions < MiniTest::Test
  def has_true
    { Test: { thing: { do: true } } }
  end

  def has_false
    { Test: { thing: { do: false } } }
  end

  def has_true_desc
    { Test: { thing: { do: 'THING' } } }
  end

  def has_true_fields
    [
      { field: :thing_do, description: 'THING', value: true, group: :thing, keys: %i[thing do] }
    ]
  end

  def has_false_fields
    [
      { field: :thing_do, description: 'THING', value: false, group: :thing, keys: %i[thing do] }
    ]
  end

  def has_deep_true
    { Test: { thing: { do: { more: { than: { this: true } } } } } }
  end

  def has_deep_false
    { Test: { thing: { do: { more: { than: { this: false } } } } } }
  end

  def has_deep_desc
    { Test: { thing: { do: { more: { than: { this: 'MORE' } } } } } }
  end

  def has_deep_fields
    [
      { field: :thing_do_more_than_this, description: 'MORE', value: true, group: :thing, keys: %i[thing do more than this] }
    ]
  end

  def has_deep_false_fields
    [
      { field: :thing_do_more_than_this, description: 'MORE', value: false, group: :thing, keys: %i[thing do more than this] }
    ]
  end

  def test_base_true
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_true) do
      res = Crossbeams::Config::UserPermissions.can_user?({}, :thing, :do)
    end
    assert res
  end

  def test_base_nested_true
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_deep_true) do
      res = Crossbeams::Config::UserPermissions.can_user?({}, :thing, :do, :more, :than, :this)
    end
    assert res
  end

  def test_base_false
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_false) do
      res = Crossbeams::Config::UserPermissions.can_user?({}, :thing, :do)
    end
    refute res
  end

  def test_base_wrong_webapp
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Someother, :BASE => has_true) do
      res = Crossbeams::Config::UserPermissions.can_user?({}, :thing, :do)
    end
    refute res
  end

  def test_base_missing
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_true) do
      res = Crossbeams::Config::UserPermissions.can_user?({}, :thing, :do_non_existent)
    end
    refute res
  end

  def test_user_true
    user = { permission_tree: { Test: { thing: { do: true } } } }
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_false) do
      res = Crossbeams::Config::UserPermissions.can_user?(user, :thing, :do)
    end
    assert res
  end

  def test_user_false
    user = { permission_tree: { Test: { thing: { do: false } } } }
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_true) do
      res = Crossbeams::Config::UserPermissions.can_user?(user, :thing, :do)
    end
    refute res
  end

  def test_user_nil
    user = { permission_tree: { Test: { missmatch: { do: true } } } }
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_false) do
      res = Crossbeams::Config::UserPermissions.can_user?(user, :thing, :do)
    end
    refute res
  end

  def test_user_other_webapp
    user = { permission_tree: { Live: { thing: { do: true } } } }
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_false) do
      res = Crossbeams::Config::UserPermissions.can_user?(user, :thing, :do)
    end
    refute res
  end

  def test_combine_with_empty
    ptree = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_true) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => has_true_desc) do
        ptree = Crossbeams::Config::UserPermissions.new({})
      end
    end
    assert_equal has_true_fields, ptree.fields
    assert_equal has_true_fields.group_by { |a| a[:group] }, ptree.grouped_fields
  end

  def test_combine_with_false
    ptree = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_true) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => has_true_desc) do
        ptree = Crossbeams::Config::UserPermissions.new(permission_tree: { thing: { do: false } })
      end
    end
    assert_equal has_false_fields, ptree.fields
  end

  def test_deep_combine_with_empty
    ptree = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_deep_true) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => has_deep_desc) do
        ptree = Crossbeams::Config::UserPermissions.new({})
      end
    end
    assert_equal has_deep_fields, ptree.fields
    assert_equal has_deep_fields.group_by { |a| a[:group] }, ptree.grouped_fields
  end

  def test_deep_combine_with_false
    ptree = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_deep_true) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => has_deep_desc) do
        ptree = Crossbeams::Config::UserPermissions.new(permission_tree: { thing: { do: { more: { than: { this: false } } } } })
      end
    end
    assert_equal has_deep_false_fields, ptree.fields
  end

  def test_deep_combine_with_false_jsonb_db_column
    ptree = nil
    repo = BaseRepo.new
    jsonb_field = repo.hash_for_jsonb_col(thing: { do: { more: { than: { this: false } } } })
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_deep_true) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => has_deep_desc) do
        ptree = Crossbeams::Config::UserPermissions.new(permission_tree: jsonb_field)
      end
    end
    assert_equal has_deep_false_fields, ptree.fields
  end

  def test_param_update
    user_permissions = nil
    params = { thing_do_more_than_this: false }
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => has_deep_true) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => has_deep_desc) do
        user_permissions = Crossbeams::Config::UserPermissions.new.apply_params(params)
      end
    end
    assert_equal has_deep_false[:Test], user_permissions
  end
end
