require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestCommonHelpers < Minitest::Test
  include CommonHelpers

  def test_select_attributes
    instance = { one: 1, two: 2 }
    row_keys = %i[one two]
    assert_equal instance, select_attributes(instance, row_keys)
    assert_equal({ one: 1, two: 2, three: 3 }, select_attributes(instance, row_keys, three: 3))
    assert_equal({ one: 1, two: 22, three: 3 }, select_attributes(instance, row_keys, three: 3, two: 22))
  end
end
