# frozen_string_literal: true

require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestRepoBase < MiniTestWithHooks

  def before_all
    super
    10.times do |i|
      DB[:users].insert(
        login_name: "usr_#{i}",
        user_name: "User #{i}",
        password_hash: "$#{i}a$10$wZQEHY77JEp93JgUUyVqgOkwhPb8bYZLswD5NVTWOKwU1ssQTYa.K",
        email: "test_#{i}@example.com",
        active: true
      )
    end
  end

  def after_all
    DB[:users].delete
    super
  end

  def test_all
    x = RepoBase.new.all(:users, User)
    assert_equal 10, x.count
    assert_instance_of(User, x.first)

    DB[:users].delete
    x = RepoBase.new.all(:users, User)
    assert_equal 0, x.count
    assert_empty x
  end

  def test_all_hash
    x = RepoBase.new.all_hash(:users)
    assert_equal 10, x.count
    assert_instance_of(Hash, x.first)

    DB[:users].delete
    x = RepoBase.new.all_hash(:users)
    assert_equal 0, x.count
    assert_empty x
  end

  def test_where_hash
    x = RepoBase.new.where_hash(:users, email: 'test_5@example.com')
    assert_equal 'usr_5', x[:login_name]

    DB[:users].where(email: 'test_5@example.com').delete
    x = RepoBase.new.where_hash(:users, email: 'test_5@example.com')
    assert_nil x
  end

  def test_find_hash
    x = RepoBase.new.where_hash(:users, email: 'test_5@example.com')
    id = x[:id]
    y = RepoBase.new.find_hash(:users, id)
    assert_equal y, x

    DB[:users].where(email: 'test_5@example.com').delete
    y = RepoBase.new.find_hash(:users, id)
    assert_nil y
  end

  def test_find
    id = RepoBase.new.where_hash(:users, email: 'test_5@example.com')[:id]
    y = RepoBase.new.find(:users, User, id)
    assert_instance_of(User, y)
    assert y.id == id

    DB[:users].where(id: id).delete
    y = RepoBase.new.find(:users, User, id)
    assert_nil y
  end

  def test_find!
    id = RepoBase.new.where_hash(:users, email: 'test_5@example.com')[:id]
    y = RepoBase.new.find!(:users, User, id)
    assert_instance_of(User, y)
    assert y.id == id

    x = assert_raises(RuntimeError) {
      RepoBase.new.find!(:users, User, 20)
    }
    assert_equal 'users: id 20 not found.', x.message
  end

  def test_where
    x = RepoBase.new.where(:users, User, email: 'test_5@example.com')
    assert_equal 'usr_5', x.login_name
    assert_instance_of User, x

    DB[:users].where(email: 'test_5@example.com').delete
    x = RepoBase.new.where(:users, User, email: 'test_5@example.com')
    assert_nil x
  end

  def test_exists?
    x = RepoBase.new.exists?(:users, email: 'test_1@example.com')
    assert x

    x = RepoBase.new.exists?(:users, email: 'test_email')
    refute x
  end

  def test_create
    attrs = {login_name: "usr",
             user_name: "User",
             password_hash: "$a$10$wZQEHY77JEp93JgUUyVqgOkwhPb8bYZLswD5NVTWOKwU1ssQTYa.K",
             email: "test@example.com",
             active: true}
    assert_nil RepoBase.new.where(:users, User, email: 'test@example.com')
    x = RepoBase.new.create(:users, attrs)
    assert_instance_of Integer, x
    usr = RepoBase.new.find(:users, User, x)
    assert_equal 'usr', usr.login_name
    assert_equal 'User', usr.user_name
    assert_equal 'test@example.com', usr.email
  end

  def test_update
    id = RepoBase.new.where(:users, User, email: 'test_1@example.com').id
    RepoBase.new.update(:users, id, email: 'updated@example.com')
    assert_equal 'updated@example.com', DB[:users].where(id: id).first[:email]
  end

  def test_delete
    id = RepoBase.new.where(:users, User, email: 'test_8@example.com').id
    RepoBase.new.delete(:users, id)
    refute DB[:users].where(id: id).first
  end

  def test_select_values
    test_query = 'SELECT * FROM users'
    x = RepoBase.new.select_values(test_query)
    y = DB[test_query].select_map
    assert_equal y, x
  end

  def test_make_order
    dataset = DB[:users]
    sel_options = { order_by: :email, desc: false }
    x = RepoBase.new.make_order(dataset, sel_options)
    assert_equal 10, x.count
    assert_kind_of Hash, x.first
    assert_equal 'test_9@example.com', x.last[:email]

    sel_options[:desc] = true
    x = RepoBase.new.make_order(dataset, sel_options)
    assert_equal 'test_9@example.com', x.first[:email]
  end

  def test_select_single
    dataset = DB[:users]
    value_name = :login_name
    result = RepoBase.new.select_single(dataset, value_name)
    expected = DB[:users].select(value_name).map{|r| r[value_name]}
    assert_equal expected, result
  end

  def test_select_two
    dataset = DB[:users]
    value_name = :login_name
    label_name = :user_name
    result = RepoBase.new.select_two(dataset, label_name, value_name)
    expected = dataset.select(label_name, value_name).map{|r| [r[label_name], r[value_name]]}
    assert_equal expected, result

    label_name = [:user_name, :active]
    result = RepoBase.new.select_two(dataset, label_name, value_name)
    expected = dataset.select(*label_name, value_name).map{|r| [label_name.map{ |nm| r[nm]}.join(' - '), r[value_name]]}
    assert_equal expected, result
  end

  def test_hash_to_jsonb_str
    hash = {test: 'Test', int: 123, array: [], bool: true, hash: {}}
    result = RepoBase.new.hash_to_jsonb_str(hash)
    expected = "{\"test\":\"Test\",\"int\":\"123\",\"array\":\"[]\",\"bool\":\"true\",\"hash\":\"{}\"}"
    assert_equal expected, result
  end

  # MethodBuilder tests
  # ----------------------------------------------------------------------------
  def test_build_for_select_basic
    klass = Class.new(RepoBase)
    klass.build_for_select(:tablename, value: :code)
    repo = klass.new
    assert_respond_to repo, :for_select_tablename
  end

  def test_build_for_select_alias
    klass = Class.new(RepoBase)
    klass.build_for_select(:tablename, value: :code, alias: 'tab')
    repo = klass.new
    assert_respond_to repo, :for_select_tab
  end

  def test_build_inactive_select_basic
    klass = Class.new(RepoBase)
    klass.build_inactive_select(:tablename, value: :code)
    repo = klass.new
    assert_respond_to repo, :for_select_inactive_tablename
  end

  def test_build_inactive_select_alias
    klass = Class.new(RepoBase)
    klass.build_inactive_select(:tablename, value: :code, alias: 'tab')
    repo = klass.new
    assert_respond_to repo, :for_select_inactive_tab
  end

  def test_crud_calls_without_wrapper
    klass = Class.new(RepoBase)
    klass.crud_calls_for(:tablename)
    repo = klass.new
    assert_respond_to repo, :create_tablename
    assert_respond_to repo, :update_tablename
    assert_respond_to repo, :delete_tablename
    refute_respond_to repo, :find_tablename
  end

  def test_crud_calls
    klass = Class.new(RepoBase)
    klass.crud_calls_for(:tablename, wrapper: User)
    repo = klass.new
    assert_respond_to repo, :create_tablename
    assert_respond_to repo, :update_tablename
    assert_respond_to repo, :delete_tablename
    assert_respond_to repo, :find_tablename
  end
end
