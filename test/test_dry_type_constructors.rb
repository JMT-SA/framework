require File.join(File.expand_path('./', __dir__), 'test_helper')

class TestDryTypeConstructors < Minitest::Test
  def test_stripped_string_required_filled
    schema = Dry::Schema.Params do
      required(:in).filled(Types::StrippedString)
    end

    res = schema.call(in: 'ABC')
    assert_equal 'ABC', res[:in]
    assert_empty res.errors

    res = schema.call(in: ' ABC ')
    assert_equal 'ABC', res[:in]
    assert_empty res.errors

    res = schema.call(in: ' ')
    assert_nil res[:in]
    assert_equal 'must be filled', res.errors[:in].first

    res = schema.call(in: nil)
    assert_nil res[:in]
    assert_equal 'must be filled', res.errors[:in].first

    res = schema.call(in: 123)
    assert_equal 123, res[:in]
    assert_equal 'must be a string', res.errors[:in].first
  end

  def test_stripped_string_required_maybe
    schema = Dry::Schema.Params do
      required(:in).maybe(Types::StrippedString)
    end

    res = schema.call(in: 'ABC')
    assert_equal 'ABC', res[:in]
    assert_empty res.errors

    res = schema.call(in: ' ABC ')
    assert_equal 'ABC', res[:in]
    assert_empty res.errors

    res = schema.call(in: ' ')
    assert_nil res[:in]
    assert_empty res.errors

    res = schema.call(in: nil)
    assert_nil res[:in]
    assert_empty res.errors

    res = schema.call(in: 123)
    assert_equal 123, res[:in]
    assert_equal 'must be a string', res.errors[:in].first
  end

  def test_int_array_required_filled
    schema = Dry::Schema.Params do
      required(:in).filled(:array).each(:integer)
    end

    res = schema.call(in: ['1', '2'])
    assert_equal [1,2], res[:in]
    assert_empty res.errors

    res = schema.call(in: [1, '2'])
    assert_equal [1,2], res[:in]
    assert_empty res.errors

    res = schema.call(in: nil)
    assert_nil res[:in]
    assert_equal 'must be filled', res.errors[:in].first

    res = schema.call(in: [])
    assert_equal [], res[:in]
    assert_equal 'must be filled', res.errors[:in].first

    res = schema.call(in: ['1', 'w'])
    assert_equal [1, 'w'], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first

    res = schema.call(in: ['1', nil])
    assert_equal [1, nil], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first

    res = schema.call(in: ['1', ''])
    assert_equal [1, ''], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first
  end

  def test_int_array_required_maybe
    schema = Dry::Schema.Params do
      required(:in).maybe(:array).each(:integer)
    end

    res = schema.call(in: ['1', '2'])
    assert_equal [1,2], res[:in]
    assert_empty res.errors

    res = schema.call(in: [1, '2'])
    assert_equal [1,2], res[:in]
    assert_empty res.errors

    res = schema.call(in: [])
    assert_equal [], res[:in]
    assert_empty res.errors

    res = schema.call(in: ['1', 'w'])
    assert_equal [1, 'w'], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first

    res = schema.call(in: ['1', nil])
    assert_equal [1, nil], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first

    res = schema.call(in: ['1', ''])
    assert_equal [1, ''], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first
  end

  def test_array_required_can_be_nil_or_ints
    schema = Dry::Schema.Params do
      required(:in).maybe(:array, min_size?: 1).maybe { each(:integer) }
    end

    res = schema.call(in: ['1', '2'])
    assert_equal [1,2], res[:in]
    assert_empty res.errors

    res = schema.call(in: [1, '2'])
    assert_equal [1,2], res[:in]
    assert_empty res.errors

    res = schema.call(in: [])
    assert_equal [], res[:in]
    assert_equal 'size cannot be less than 1', res.errors[:in].first

    res = schema.call(in: nil)
    assert_nil res[:in]
    assert_empty res.errors

    res = schema.call(in: ['1', 'w'])
    assert_equal [1, 'w'], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first

    res = schema.call(in: ['1', nil])
    assert_equal [1, nil], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first

    res = schema.call(in: ['1', ''])
    assert_equal [1, ''], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first
  end
end
