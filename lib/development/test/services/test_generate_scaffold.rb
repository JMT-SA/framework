require File.join(File.expand_path('../../../../../test', __FILE__), 'test_helper')

class GenerateNewScaffoldTest < MiniTestWithHooks
  def before_all
    super
    # DB[:table].insert(column: 1)
  end

  def after_all
    # DB[:table].delete
    super
  end

  def around
    DB.transaction(rollback: :always, savepoint: true, auto_savepoint: true) do
      super
    end
  end

  def around_all
    DB.transaction(rollback: :always) do
      super
    end
  end

  def test_nothing
    p "hello world"
    assert true
  end

  def test_db
    repo = SecurityGroupRepo.new
    assert_nil repo.find_security_group(1)
  end

  def test_add_db
    repo = SecurityGroupRepo.new
    assert 1, repo.create_security_group(security_group_name: 'a_test')
  end
end
