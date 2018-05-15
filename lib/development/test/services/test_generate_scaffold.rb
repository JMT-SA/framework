require File.join(File.expand_path('../../../../test', __dir__), 'test_helper')

class GenerateNewScaffoldTest < MiniTestWithHooks
  def before_all
    super
    # DB[:table].insert(column: 1)
  end

  def after_all
    # DB[:table].delete
    super
  end

  def test_nothing
    # p "hello world"
    assert true
  end

  def test_db
    repo = SecurityApp::SecurityGroupRepo.new
    assert_nil repo.find_security_group(1)
  end

  def test_add_db
    repo = SecurityApp::SecurityGroupRepo.new
    assert 1, repo.create_security_group(security_group_name: 'a_test')
  end
end
