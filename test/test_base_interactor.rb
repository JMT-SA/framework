require File.join(File.expand_path('./../', __FILE__), 'test_helper')

class TestBaseInteractor < MinitestInteractor

  def interactor
    BaseInteractor.new(current_user, {}, {}, {})
  end

  def test_exists?
    BaseRepo.any_instance.expects(:exists?).returns(true)
    interactor.exists?(:users, 1)
  end

  def test_validation_failed_response
    results = OpenStruct.new(messages: { roles: ['You did not choose a role'] })
    x = interactor.validation_failed_response(results)
    expected = OpenStruct.new( success: false,
                               instance: {},
                               errors: results.messages,
                               message: 'Validation error')
    assert_equal expected, x
  end

  def test_validation_failed_response_with_instance
    results = OpenStruct.new(messages: { roles: ['You did not choose a role'] }, id: 1, name: 'fred')
    x = interactor.validation_failed_response(results)
    expected = OpenStruct.new( success: false,
                               instance: {id: 1, name: 'fred'},
                               errors: results.messages,
                               message: 'Validation error')
    assert_equal expected, x
  end

  def test_failed_response
    mes = 'Failed'
    x = interactor.failed_response(mes, current_user)
    expected = OpenStruct.new( success: false,
                               instance: current_user,
                               errors: {},
                               message: mes)
    assert_equal expected, x
  end

  def test_success_response
    mes = 'Success'
    x = interactor.success_response(mes, current_user)
    expected = OpenStruct.new( success: true,
                               instance: current_user,
                               errors: {},
                               message: mes)
    assert_equal expected, x
  end
end
