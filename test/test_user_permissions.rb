# frozen_string_literal: true

require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestUserPemissions < MiniTest::Test
  class EntityData < Dry::Struct
    # attribute :permission_tree, Types::JSON::Hash
    attribute :permission_tree, Types::Hash
  end

  def config(key)
    {
      true: { Test: { thing: { do: true } } },
      false: { Test: { thing: { do: false } } },
      deep_true:  { Test: { thing: { do: { more: { than: { this: true } } } } } },
      deep_false:  { Test: { thing: { do: { more: { than: { this: false } } } } } }
    }[key]
  end

  def description(key)
    {
      true: { Test: { thing: { do: 'THING' } } },
      deep: { Test: { thing: { do: { more: { than: { this: 'MORE' } } } } } }
    }[key]
  end

  def fields(key)
    {
      true: [ { field: :thing_do, description: 'THING', value: true, group: :thing, keys: %i[thing do] } ],
      false: [ { field: :thing_do, description: 'THING', value: false, group: :thing, keys: %i[thing do] } ],
      deep: [ { field: :thing_do_more_than_this, description: 'MORE', value: true, group: :thing, keys: %i[thing do more than this] } ],
      deep_false: [ { field: :thing_do_more_than_this, description: 'MORE', value: false, group: :thing, keys: %i[thing do more than this] } ]
    }[key]
  end

  def test_base_true
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:true)) do
      res = Crossbeams::Config::UserPermissions.can_user?({}, :thing, :do)
    end
    assert res
  end

  def test_base_nested_true
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:deep_true)) do
      res = Crossbeams::Config::UserPermissions.can_user?({}, :thing, :do, :more, :than, :this)
    end
    assert res
  end

  def test_base_false
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:false)) do
      res = Crossbeams::Config::UserPermissions.can_user?({}, :thing, :do)
    end
    refute res
  end

  def test_base_wrong_webapp
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Someother, :BASE => config(:true)) do
      res = Crossbeams::Config::UserPermissions.can_user?({}, :thing, :do)
    end
    refute res
  end

  def test_base_missing
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:true)) do
      res = Crossbeams::Config::UserPermissions.can_user?({}, :thing, :do_non_existent)
    end
    refute res
  end

  def test_user_true
    user = { permission_tree: { Test: { thing: { do: true } } } }
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:false)) do
      res = Crossbeams::Config::UserPermissions.can_user?(user, :thing, :do)
    end
    assert res
  end

  def test_user_false
    user = { permission_tree: { Test: { thing: { do: false } } } }
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:true)) do
      res = Crossbeams::Config::UserPermissions.can_user?(user, :thing, :do)
    end
    refute res
  end

  def test_user_false_jsonb_col
    str_hash = UtilityFunctions.stringify_keys(Test: { thing: { do: false } })
    user = EntityData.new(permission_tree: str_hash)

    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:true)) do
      res = Crossbeams::Config::UserPermissions.can_user?(user, :thing, :do)
    end
    refute res
  end

  def test_user_nil
    user = { permission_tree: nil }
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:false)) do
      res = Crossbeams::Config::UserPermissions.can_user?(user, :thing, :do)
    end
    refute res
  end

  def test_user_other_webapp
    user = { permission_tree: { Live: { thing: { do: true } } } }
    res = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:false)) do
      res = Crossbeams::Config::UserPermissions.can_user?(user, :thing, :do)
    end
    refute res
  end

  def test_combine_with_empty
    ptree = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:true)) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => description(:true)) do
        ptree = Crossbeams::Config::UserPermissions.new({})
      end
    end
    assert_equal fields(:true), ptree.fields
    assert_equal fields(:true).group_by { |a| a[:group] }, ptree.grouped_fields
  end

  def test_combine_with_false
    ptree = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:true)) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => description(:true)) do
        ptree = Crossbeams::Config::UserPermissions.new(permission_tree: { Test: { thing: { do: false } } })
      end
    end
    assert_equal fields(:false), ptree.fields
  end

  def test_deep_combine_with_empty
    ptree = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:deep_true)) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => description(:deep)) do
        ptree = Crossbeams::Config::UserPermissions.new({})
      end
    end
    assert_equal fields(:deep), ptree.fields
    assert_equal fields(:deep).group_by { |a| a[:group] }, ptree.grouped_fields
  end

  def test_deep_combine_with_false
    ptree = nil
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:deep_true)) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => description(:deep)) do
        ptree = Crossbeams::Config::UserPermissions.new(permission_tree: { Test: {thing: { do: { more: { than: { this: false } } } } } })
      end
    end
    assert_equal fields(:deep_false), ptree.fields
  end

  def test_deep_combine_with_false_jsonb_db_column
    ptree = nil
    jsonb_field = UtilityFunctions.stringify_keys(Test: { thing: { do: { more: { than: { this: false } } } } })
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:deep_true)) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => description(:deep)) do
        ptree = Crossbeams::Config::UserPermissions.new(permission_tree: jsonb_field)
      end
    end
    assert_equal fields(:deep_false), ptree.fields
  end

  def test_param_update
    user_permissions = nil
    params = { thing_do_more_than_this: false }
    Crossbeams::Config::UserPermissions.stub_consts(:WEBAPP => :Test, :BASE => config(:deep_true)) do
      Crossbeams::Config::UserPermissions.stub_consts(:DOCUMENTATION => description(:deep)) do
        user_permissions = Crossbeams::Config::UserPermissions.new.apply_params(params)
      end
    end
    assert_equal config(:deep_false), user_permissions
  end
end
