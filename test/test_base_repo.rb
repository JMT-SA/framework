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
      BaseRepo.new.find!(:users, DevelopmentApp::User, 299999)
    }
    assert_equal 'users: id 299999 not found.', x.message
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
    actual = BaseRepo.new.select_values(:users, :id)
    expect = DB[:users].select_map(:id)
    assert_equal expect, actual

    actual = BaseRepo.new.select_values(:users, :id, id: [1, 2])
    expect = DB[:users].where(id: [1, 2]).select_map(:id)
    assert_equal expect, actual
  end

  def test_select_values_in_order
    assert_raises { BaseRepo.new.select_values_in_order(:users, :id) }

    actual = BaseRepo.new.select_values_in_order(:users, :id, order: :id)
    expect = DB[:users].order(:id).select_map(:id)
    assert_equal expect, actual

    actual = BaseRepo.new.select_values_in_order(:users, :id, order: :id, where: { id: [1, 2] })
    expect = DB[:users].where(id: [1, 2]).order(:id).select_map(:id)
    assert_equal expect, actual

    actual = BaseRepo.new.select_values_in_order(:users, :id, order: :id, where: { id: [1, 2] }, descending: true)
    expect = DB[:users].where(id: [1, 2]).reverse(:id).select_map(:id)
    assert_equal expect, actual
  end

  def test_hash_for_jsonb_col
    hash = {test: 'Test', int: 123, array: [], bool: true, hash: {}}
    result = BaseRepo.new.hash_for_jsonb_col(hash)
    expected = 'Sequel::Postgres::JSONBHash'
    assert_equal expected, result.class.name

    result = BaseRepo.new.hash_for_jsonb_col(nil)
    assert_nil result
  end

  def test_array_for_db_col
    arr = [1, 2, 3]
    result = BaseRepo.new.array_for_db_col(arr)
    expected = 'Sequel::Postgres::PGArray'
    assert_equal expected, result.class.name

    result = BaseRepo.new.array_for_db_col(nil)
    assert_nil result
  end

  def test_prepare_array_values_for_db
    params = { a: 1, b: '2', c: [1,2,3], d: 123.3, e: [1,2], f: nil, g: [] }

    result = BaseRepo.new.prepare_array_values_for_db(params)
    expected = ["a: Integer", "b: String", "c: Sequel::Postgres::PGArray", "d: Float", "e: Sequel::Postgres::PGArray", "f: NilClass", "g: Sequel::Postgres::PGArray"]
    assert_equal expected, result.map { |k, v| "#{k}: #{v.class.name}" }

    test_schema = Dry::Schema.Params do
      required(:a).filled(:integer)
      required(:b).filled(Types::StrippedString)
      required(:c).filled(:array).each(:integer)
      required(:d).filled(:decimal)
      required(:e).filled(:array).each(:integer)
      required(:f).maybe(Types::StrippedString)
      required(:g).maybe(:array).each(:integer)
    end

    res = test_schema.call(params)
    p res unless res.errors.empty?
    result = BaseRepo.new.prepare_array_values_for_db(res)
    expected = ["a: Integer", "b: String", "c: Sequel::Postgres::PGArray", "d: BigDecimal", "e: Sequel::Postgres::PGArray", "f: NilClass", "g: Sequel::Postgres::PGArray"]
    assert_equal expected, result.map { |k, v| "#{k}: #{v.class.name}" }
    
    result = BaseRepo.new.prepare_array_values_for_db(nil)
    assert_nil result
  end

  def test_optgroup_array
    rows = [{type: 'A', sub: 'B', id: 1}, {type: 'A', sub: 'C', id: 2}, {type: 'B', sub: 'D', id: 4}, {type: 'A', sub: 'E', id: 7}]
    res = BaseRepo.new.optgroup_array(rows, :type, :sub, :id)
    assert_equal %w[A B], res.keys.sort
    assert_equal %w[B C E], res['A'].map(&:first)
    assert_equal [1, 2, 7], res['A'].map(&:last)
    assert_equal %w[D], res['B'].map(&:first)
    assert_equal [4], res['B'].map(&:last)

    res = BaseRepo.new.optgroup_array(rows, :type, :sub)
    assert_equal %w[A B], res.keys.sort
    assert_equal %w[B C E], res['A'].map(&:first)
    assert_equal %w[B C E], res['A'].map(&:last)
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
    klass.crud_calls_for(:users)
    repo = klass.new
    assert_respond_to repo, :create_users
    assert_respond_to repo, :update_users
    assert_respond_to repo, :delete_users
    refute_respond_to repo, :find_users
  end

  def test_crud_calls_fails_for_table_that_does_not_exist
    klass = Class.new(BaseRepo)
    assert_raises(ArgumentError) { klass.crud_calls_for(:some_table_no_one_would_want_to_create) }
  end

  def test_crud_calls_with_schema
    klass = Class.new(BaseRepo)
    klass.crud_calls_for(:users, schema: :public)
    repo = klass.new
    assert_respond_to repo, :create_users
    assert_respond_to repo, :update_users
    assert_respond_to repo, :delete_users
    refute_respond_to repo, :find_users
  end

  def test_crud_calls_with_exclusion
    klass = Class.new(BaseRepo)
    klass.crud_calls_for(:users, exclude: %i[update delete])
    repo = klass.new
    assert_respond_to repo, :create_users
    refute_respond_to repo, :update_users
    refute_respond_to repo, :delete_users
    refute_respond_to repo, :find_users
  end

  def test_crud_calls
    klass = Class.new(BaseRepo)
    klass.crud_calls_for(:users, wrapper: DevelopmentApp::User)
    repo = klass.new
    assert_respond_to repo, :create_users
    assert_respond_to repo, :update_users
    assert_respond_to repo, :delete_users
    assert_respond_to repo, :find_users
  end

  def test_find_with_associations
    repo = BaseRepo.new
    user1 = repo.where_hash(:users, login_name: "usr_1")
    user2 = repo.where_hash(:users, login_name: "usr_2")
    repo.update(:users, user2[:id], active: false)
    sg_id = DB[:security_groups].insert(security_group_name: 'SG-TEST1')
    func_id = DB[:functional_areas].insert(functional_area_name: 'F-TEST1')
    prog_id = DB[:programs].insert(program_name: 'P-TEST1', program_sequence: 1, functional_area_id: func_id)
    DB[:programs_users].insert(user_id: user1[:id], program_id: prog_id, security_group_id: sg_id)
    DB[:programs_users].insert(user_id: user2[:id], program_id: prog_id, security_group_id: sg_id)
    DB[:program_functions].insert(program_function_name: 'PF-TEST1', program_id: prog_id, url: '/some/path')

    # Validation
    assert_raises(KeyError) { repo.find_with_association(:functional_areas, func_id, sub_tables: [{ miss_spelled_sub_table: :programs }]) }
    assert_raises(ArgumentError) { repo.find_with_association('functional_areas', func_id, sub_tables: [{ sub_table: :programs }]) }
    assert_raises(ArgumentError) { repo.find_with_association(:functional_areas, func_id, sub_tables: [{ sub_table: :programs, non_existent_key: 'WRONG' }]) }

    # No association specified - just returns functional_areas Hash.
    res = repo.find_with_association(:functional_areas, func_id)
    assert_nil res[:programs]
    assert_equal 'F-TEST1', res[:functional_area_name]

    # Basic association (belongs_to)
    res = repo.find_with_association(:functional_areas, func_id, sub_tables: [{ sub_table: :programs }])
    assert_equal 1, res[:programs].length
    assert res[:programs].first.length > 2

    # Certain cols only
    res = repo.find_with_association(:functional_areas, func_id, sub_tables: [{ sub_table: :programs, columns: [:id, :program_name] }])
    assert_equal 1, res[:programs].length
    assert_equal 2, res[:programs].first.length

    # Join table association.
    res = repo.find_with_association(:programs, prog_id, sub_tables: [{ sub_table: :users, uses_join_table: true }])
    assert_equal 2, res[:users].length

    # Join table association with provided join table.
    res = repo.find_with_association(:programs, prog_id, sub_tables: [{ sub_table: :users, join_table: :programs_users }])
    assert_equal 2, res[:users].length

    # Active only
    res = repo.find_with_association(:programs, prog_id, sub_tables: [{ sub_table: :users, uses_join_table: true, active_only: true }])
    assert_equal 1, res[:users].length
    assert_equal 'usr_1', res[:users].first[:login_name]

    # Inactive only
    res = repo.find_with_association(:programs, prog_id, sub_tables: [{ sub_table: :users, uses_join_table: true, inactive_only: true }])
    assert_equal 1, res[:inactive_users].length
    assert_equal 'usr_2', res[:inactive_users].first[:login_name]

    # More than one association
    res = repo.find_with_association(:programs, prog_id, sub_tables: [{ sub_table: :users, uses_join_table: true },
                                                                      { sub_table: :program_functions }])
    assert_equal 2, res[:users].length
    assert_equal 1, res[:program_functions].length

    # Parent association
    res = repo.find_with_association(:programs, prog_id, parent_tables: [{ parent_table: :functional_areas, columns: [:functional_area_name] }])
    assert_equal 'F-TEST1', res[:functional_area][:functional_area_name]

    # Parent association - flattened columns
    res = repo.find_with_association(:programs, prog_id, parent_tables: [{ parent_table: :functional_areas, columns: [:functional_area_name],
                                                                           flatten_columns: { functional_area_name: :funcname } }])
    assert_equal 'F-TEST1', res[:funcname]

    # # Parent association - non-matching foreign key.
    # res = repo.find_with_association(:programs, dummy_id, parent_tables: [{ parent_table: :security_groups, columns: [:security_group_name],
    #                                                                         flatten_columns: { security_group_name: :secname },
    #                                                                         foreign_key: :functional_area_id }])
    # assert_equal 'SG-TEST1', res[:secname]

    # Function lookup
    res = repo.find_with_association(:programs, prog_id, lookup_functions: [{ function: :fn_party_role_name, args: [:functional_area_id], col_name: :customer_name }])
    assert res.keys.include?(:customer_name)
  end
end
