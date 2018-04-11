require File.join(File.expand_path('./', __dir__), 'test_helper')

class TestDryTypeConstructors < Minitest::Test
  def test_stripped_string_required_filled
    schema = Dry::Validation.Form do
      configure { config.type_specs = true }

      required(:in, Types::StrippedString).filled(:str?)
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
    schema = Dry::Validation.Form do
      configure { config.type_specs = true }

      required(:in, Types::StrippedString).maybe(:str?)
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
    schema = Dry::Validation.Form do
      configure { config.type_specs = true }

      required(:in, Types::IntArray).filled { each(:int?) }
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
    assert_equal [1, nil], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first
  end

  def test_int_array_required_maybe
    schema = Dry::Validation.Form do
      configure { config.type_specs = true }

      required(:in, Types::IntArray) { each(:int?) }
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

    res = schema.call(in: nil)
    assert_nil res[:in]
    assert_equal 'must be an array', res.errors[:in].first

    res = schema.call(in: ['1', 'w'])
    assert_equal [1, 'w'], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first

    res = schema.call(in: ['1', nil])
    assert_equal [1, nil], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first

    res = schema.call(in: ['1', ''])
    assert_equal [1, nil], res[:in]
    assert_equal 'must be an integer', res.errors[:in][1].first
  end

  def test_int_array_required_any_type
    schema = Dry::Validation.Form do
      configure { config.type_specs = true }

      required(:in, Types::IntArray).filled
    end
    res = schema.call(in: ['1', '2'])
    assert_equal [1,2], res[:in]
    assert_empty res.errors

    res = schema.call(in: [1, '2'])
    assert_equal [1,2], res[:in]
    assert_empty res.errors

    res = schema.call(in: [])
    assert_equal [], res[:in]
    assert_equal 'must be filled', res.errors[:in].first

    res = schema.call(in: ['1', 'w'])
    assert_equal [1, 'w'], res[:in]
    assert_empty res.errors

    res = schema.call(in: ['1', nil])
    assert_equal [1, nil], res[:in]
    assert_empty res.errors

    res = schema.call(in: ['1', ''])
    assert_equal [1, nil], res[:in]
    assert_empty res.errors
  end
end
