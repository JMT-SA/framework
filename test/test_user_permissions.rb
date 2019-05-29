# frozen_string_literal: true

require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestUserPemissions < MiniTest::Test
  def has_true
    { Test: { thing: { do: true } } }
  end

  def has_deep_true
    { Test: { thing: { do: { more: { than: { this: true } } } } } }
  end

  def has_false
    { Test: { thing: { do: false } } }
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
end
