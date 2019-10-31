require File.join(File.expand_path('./', __dir__), 'test_helper')

class TestLocalStore < Minitest::Test
  def setup
    # Note: use a string for the user_id arg so as to avoid clashing with real user_ids.
    @store = LocalStore.new('abc')
    @ip_store = LocalStore.new('abc', '192.168.0.1')
  end

  def teardown
    # A store is only persisted on write, so the file might not exist at teardown time.
    @store.destroy if File.exist?(@store.send(:filename))
    @ip_store.destroy if File.exist?(@ip_store.send(:filename))
  end

  def test_read_once
    @store.write(:a, 'b')

    assert_equal 'b', @store.read_once(:a)
    assert_nil @store.read_once(:a)
  end

  def test_reads
    @store.write(:a, 'b')

    assert_equal 'b', @store.read(:a)
    assert_equal 'b', @store.read(:a)
  end

  def test_read_with_default
    assert_equal 'z', @store.read(:a, 'z')
  end

  def test_write
    @store.write(:a, 'b')

    assert_equal 'b', @store.read(:a)

    @store.write(:a, 'c')
    assert_equal 'c', @store.read(:a)
  end

  def test_delete
    @store.write(:a, 'b')

    assert_equal 'b', @store.read(:a)

    @store.delete(:a)
    assert_nil @store.read(:a)
  end

  def test_dup
    @store.write(:a, 'b')
    @store.write(:a, 'c')
    assert_equal 'c', @store.read(:a)
  end

  def test_with_ip_address
    @ip_store.write(:a, 'b')

    assert_equal 'b', @ip_store.read_once(:a)
    assert_nil @ip_store.read_once(:a)
    @ip_store.write(:a, 'b')

    assert_equal 'b', @ip_store.read(:a)
    assert_equal 'b', @ip_store.read(:a)
  end
end
