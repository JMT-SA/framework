require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestUtilityFunctions < Minitest::Test

  def test_camelize
    test_string = "my_underscored_test_string"
    assert_equal "MyUnderscoredTestString", UtilityFunctions.camelize(test_string)

    test_string = "my_underscored/test_string"
    assert_equal "MyUnderscored::TestString", UtilityFunctions.camelize(test_string)

    # it responds correctly to digits:
    test_string = 'my_under1scored_test2_string3_4_5'
    assert_equal 'MyUnder1scoredTest2String345', UtilityFunctions.camelize(test_string)

    test_string = 'my_under1scored/_test2_string3/_4_5'
    assert_equal 'MyUnder1scored::Test2String3::45', UtilityFunctions.camelize(test_string)
  end

  def test_simple_single
    # https://www.grammarly.com/blog/plural-nouns/
    # This needs to be rewritten to be fully functional || find a gem for this.
    # Methods like singularize and pluralize are extremely useful in large apps.
    # Dry::Iterator
    test_string = 'ponies'
    assert_equal 'pony', UtilityFunctions.simple_single(test_string)
    test_string = 'dresses'
    assert_equal 'dress', UtilityFunctions.simple_single(test_string)
    test_string = 'responses'
    assert_equal 'response', UtilityFunctions.simple_single(test_string)
    test_string = 'people'
    assert_equal 'person', UtilityFunctions.simple_single(test_string)
  end

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
