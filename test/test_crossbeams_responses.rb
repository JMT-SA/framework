require File.join(File.expand_path('./', __dir__), 'test_helper')

class TestCrossbeamsResponses < Minitest::Test
  def setup
    @test_obj = Object.new
    @test_obj.extend Crossbeams::Responses
  end

  def test_success_response_without_instance
    res = @test_obj.success_response('OK')

    assert res.success
    assert_equal 'OK', res.message
    assert_empty res.errors
    assert_equal({}, res.instance)
  end

  def test_success_response_with_instance
    res = @test_obj.success_response('OK', { thing: 'A' })

    assert res.success
    assert_equal 'OK', res.message
    assert_empty res.errors
    assert_equal 'A', res.instance[:thing]
  end

  def test_failed_response_without_instance
    res = @test_obj.failed_response('OHNO')

    refute res.success
    assert_equal 'OHNO', res.message
    assert_empty res.errors
    assert_equal({}, res.instance)
  end

  def test_failed_response_with_instance
    res = @test_obj.failed_response('OHNO', { thing: 'A' })

    refute res.success
    assert_equal 'OHNO', res.message
    assert_empty res.errors
    assert_equal 'A', res.instance[:thing]
  end

  def test_validation_failed
    res = @test_obj.validation_failed_response(OpenStruct.new(messages: 'OHNO'))

    refute res.success
    assert_equal 'Validation error', res.message
    assert_equal 'OHNO', res.errors
    assert_equal({}, res.instance)
  end

  def test_validation_failed_with_struct
    res = @test_obj.validation_failed_response(OpenStruct.new(messages: 'OHNO', thing: 'A'))

    assert_equal 'A', res.instance[:thing]
  end

  def test_validation_failed_with_hash
    res = @test_obj.validation_failed_response(messages: 'OHNO', thing: 'A')

    assert_equal 'A', res.instance[:thing]
  end

  def test_validation_failed_with_dry
    schema = Dry::Schema.Params do
      required(:in).filled(Types::StrippedString)
    end
    validation = schema.call(dummy: nil)
    res = @test_obj.validation_failed_response(validation)

    refute res.success
    assert_equal 'Validation error', res.message
    assert_equal({:in=>["is missing"]}, res.errors)
    assert_equal({}, res.instance)
  end

  def test_validation_failed_with_dry_and_instance
    schema = Dry::Schema.Params do
      required(:in).filled(Types::StrippedString)
      required(:other).filled(Types::StrippedString)
    end
    validation = schema.call(other: 'abc')
    res = @test_obj.validation_failed_response(validation)

    assert_equal({:in=>["is missing"]}, res.errors)
    assert_equal({ other: 'abc' }, res.instance)
  end

  def test_mixed_validation_failed
    schema = Dry::Schema.Params do
      required(:in).filled(Types::StrippedString)
      required(:other).filled(Types::StrippedString)
    end
    validation = schema.call(other: 'abc')

    schema2 = Dry::Schema.Params do
      required(:more).filled(:integer)
      required(:extra).filled(Types::StrippedString)
    end
    validation2 = schema2.call(more: 'str')
    res = @test_obj.mixed_validation_failed_response(validation, validation2)

    assert_equal({:in=>["is missing"], :more => ['must be an integer'], :extra => ['is missing']}, res.errors)
    assert_equal({ other: 'abc', more: 'str' }, res.instance)
  end

  def test_mixed_validation_failed_with_hash
    schema = Dry::Schema.Params do
      required(:in).filled(Types::StrippedString)
      required(:other).filled(Types::StrippedString)
    end
    validation = schema.call(other: 'abc')

    validation2 = { more: 'str', messages: {more: ['must be an integer'], extra: ['is missing'] } } # schema2.call(more: 'str')
    res = @test_obj.mixed_validation_failed_response(validation, validation2)

    assert_equal({:in=>["is missing"], :more => ['must be an integer'], :extra => ['is missing']}, res.errors)
    assert_equal({ other: 'abc', more: 'str' }, res.instance)
  end
end
