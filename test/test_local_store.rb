require File.join(File.expand_path('./', __dir__), 'test_helper')

class TestLocalStore < Minitest::Test
  def setup
    # Note: use a string for the user_id arg so as to avoid clashing with real user_ids.
    @store = LocalStore.new('abc')
  end

  def teardown
    @store.destroy
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
end
