# frozen_string_literal: true

require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestBaseRepo < MiniTestWithHooks

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
    x = BaseRepo.new.all(:users, DevelopmentApp::User)
    assert_equal 10, x.count
    assert_instance_of(DevelopmentApp::User, x.first)

    DB[:users].delete
    x = BaseRepo.new.all(:users, DevelopmentApp::User)
    assert_equal 0, x.count
    assert_empty x
  end

  def test_all_hash
    x = BaseRepo.new.all_hash(:users)
    assert_equal 10, x.count
    assert_instance_of(Hash, x.first)

    DB[:users].delete
    x = BaseRepo.new.all_hash(:users)
    assert_equal 0, x.count
    assert_empty x
  end

  def test_where_hash
    x = BaseRepo.new.where_hash(:users, email: 'test_5@example.com')
    assert_equal 'usr_5', x[:login_name]

    DB[:users].where(email: 'test_5@example.com').delete
    x = BaseRepo.new.where_hash(:users, email: 'test_5@example.com')
    assert_nil x
  end

  def test_find_hash
    x = BaseRepo.new.where_hash(:users, email: 'test_5@example.com')
    id = x[:id]
    y = BaseRepo.new.find_hash(:users, id)
    assert_equal y, x

    DB[:users].where(email: 'test_5@example.com').delete
    y = BaseRepo.new.find_hash(:users, id)
    assert_nil y
  end

  def test_find
    id = BaseRepo.new.where_hash(:users, email: 'test_5@example.com')[:id]
    y = BaseRepo.new.find(:users, DevelopmentApp::User, id)
    assert_instance_of(DevelopmentApp::User, y)
    assert y.id == id

    DB[:users].where(id: id).delete
    y = BaseRepo.new.find(:users, DevelopmentApp::User, id)
    assert_nil y
  end

  def test_find!
    id = BaseRepo.new.where_hash(:users, email: 'test_5@example.com')[:id]
    y = BaseRepo.new.find!(:users, DevelopmentApp::User, id)
    assert_instance_of(DevelopmentApp::User, y)
    assert y.id == id

    x = assert_raises(RuntimeError) {
      BaseRepo.new.find!(:users, DevelopmentApp::User, 20)
    }
    assert_equal 'users: id 20 not found.', x.message
  end

  def test_where
    x = BaseRepo.new.where(:users, DevelopmentApp::User, email: 'test_5@example.com')
    assert_equal 'usr_5', x.login_name
    assert_instance_of DevelopmentApp::User, x

    DB[:users].where(email: 'test_5@example.com').delete
    x = BaseRepo.new.where(:users, DevelopmentApp::User, email: 'test_5@example.com')
    assert_nil x
  end

  def test_exists?
    x = BaseRepo.new.exists?(:users, email: 'test_1@example.com')
    assert x

    x = BaseRepo.new.exists?(:users, email: 'test_email')
    refute x
  end

  def test_create
    attrs = {login_name: "usr",
             user_name: "User",
             password_hash: "$a$10$wZQEHY77JEp93JgUUyVqgOkwhPb8bYZLswD5NVTWOKwU1ssQTYa.K",
             email: "test@example.com",
             active: true}
    assert_nil BaseRepo.new.where(:users, DevelopmentApp::User, email: 'test@example.com')
    x = BaseRepo.new.create(:users, attrs)
    assert_instance_of Integer, x
    usr = BaseRepo.new.find(:users, DevelopmentApp::User, x)
    assert_equal 'usr', usr.login_name
    assert_equal 'User', usr.user_name
    assert_equal 'test@example.com', usr.email
  end

  def test_update
    id = BaseRepo.new.where(:users, DevelopmentApp::User, email: 'test_1@example.com').id
    BaseRepo.new.update(:users, id, email: 'updated@example.com')
    assert_equal 'updated@example.com', DB[:users].where(id: id).first[:email]
  end

  def test_delete
    id = BaseRepo.new.where(:users, DevelopmentApp::User, email: 'test_8@example.com').id
    BaseRepo.new.delete(:users, id)
    refute DB[:users].where(id: id).first
  end

  def test_deactivate
    user = BaseRepo.new.where(:users, DevelopmentApp::User, email: 'test_8@example.com')
    BaseRepo.new.deactivate(:users, user.id)
    assert user.active
    refute DB[:users].where(id: user.id).first[:active]
  end

  def test_select_values
    test_query = 'SELECT * FROM users'
    x = BaseRepo.new.select_values(test_query)
    y = DB[test_query].select_map
    assert_equal y, x
  end

  def test_hash_to_jsonb_str
    hash = {test: 'Test', int: 123, array: [], bool: true, hash: {}}
    result = BaseRepo.new.hash_to_jsonb_str(hash)
    expected = "{\"test\":\"Test\",\"int\":\"123\",\"array\":\"[]\",\"bool\":\"true\",\"hash\":\"{}\"}"
    assert_equal expected, result
  end

  # MethodBuilder tests
  # ----------------------------------------------------------------------------
  def test_build_for_select_basic
    klass = Class.new(BaseRepo)
    klass.build_for_select(:tablename, value: :code)
    repo = klass.new
    assert_respond_to repo, :for_select_tablename
  end

  def test_build_for_select_alias
    klass = Class.new(BaseRepo)
    klass.build_for_select(:tablename, value: :code, alias: 'tab')
    repo = klass.new
    assert_respond_to repo, :for_select_tab
  end

  def test_build_inactive_select_basic
    klass = Class.new(BaseRepo)
    klass.build_inactive_select(:tablename, value: :code)
    repo = klass.new
    assert_respond_to repo, :for_select_inactive_tablename
  end

  def test_build_inactive_select_alias
    klass = Class.new(BaseRepo)
    klass.build_inactive_select(:tablename, value: :code, alias: 'tab')
    repo = klass.new
    assert_respond_to repo, :for_select_inactive_tab
  end

  def test_for_select_ordered
    klass = Class.new(BaseRepo)
    klass.build_for_select(:users, value: :login_name, order_by: :login_name)
    repo = klass.new
    users = repo.for_select_users
    assert_equal 'usr_0', users.first
    assert_equal 'usr_9', users.last
  end

  def test_for_select_descending
    klass = Class.new(BaseRepo)
    klass.build_for_select(:users, value: :login_name, order_by: :login_name, desc: true)
    repo = klass.new
    users = repo.for_select_users
    assert_equal 'usr_9', users.first
    assert_equal 'usr_0', users.last
  end

  def test_for_select_two
    klass = Class.new(BaseRepo)
    klass.build_for_select(:users, value: :login_name, label: :user_name, order_by: :login_name)
    repo = klass.new
    users = repo.for_select_users
    assert_equal ['User 0', 'usr_0'], users.first
    assert_equal ['User 9', 'usr_9'], users.last
  end

  def test_crud_calls_without_wrapper
    klass = Class.new(BaseRepo)
    klass.crud_calls_for(:tablename)
    repo = klass.new
    assert_respond_to repo, :create_tablename
    assert_respond_to repo, :update_tablename
    assert_respond_to repo, :delete_tablename
    refute_respond_to repo, :find_tablename
  end

  def test_crud_calls
    klass = Class.new(BaseRepo)
    klass.crud_calls_for(:tablename, wrapper: DevelopmentApp::User)
    repo = klass.new
    assert_respond_to repo, :create_tablename
    assert_respond_to repo, :update_tablename
    assert_respond_to repo, :delete_tablename
    assert_respond_to repo, :find_tablename
  end
end
