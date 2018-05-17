require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestUtilityFunctions < Minitest::Test

  def test_newline_and_spaces
    assert_equal "\n    ", UtilityFunctions.newline_and_spaces(4)
  end

  def test_comma_newline_and_spaces
    assert_equal ",\n    ", UtilityFunctions.comma_newline_and_spaces(4)
  end

  def test_spaces_from_string_lengths
    skip 'not currently in use'
  end
end
