module Crossbeams
  # Methods for creating Response objects.
  module Responses
    # Create a response object with validation errors.
    # Returns:
    #   - success: false.
    #   - instance: a Hash of the object that failed validation.
    #   - errors: the error messages.
    #   - message: "Validation error".
    #
    # validation results must either be a Dry::Validation::Result or a Hash.
    # The Hash should have attributes for the object in error and a key `:messages`.
    # `:messages` must be in the same format as Dry::Validation::Result.messages.
    # i.e `messages: { field1: ['error', 'another error'], field2: ['an err'] }`
    #
    # @param validation_results [Hash, Dry::Validation::Result] the validation object and messages.
    # @return [OpenStruct] the response object.
    def validation_failed_response(validation_results)
      OpenStruct.new(success: false,
                     instance: validation_results.is_a?(Dry::Validation::Result) ? validation_results.to_h : validation_results.to_h.reject { |k, _| k == :messages },
                     errors: validation_results.messages,
                     message: 'Validation error')
    end

    # Create a failed response object.
    # Returns:
    #   - success: false.
    #   - instance: the passed-in instance. Can be an empty Hash.
    #   - errors: an empty hash.
    #   - message: the passed-in message.
    #
    #
    # @param message [String] the error messages.
    # @param instance [nil, Object] the relevant instance in error.
    # @return [OpenStruct] the response object.
    def failed_response(message, instance = nil)
      OpenStruct.new(success: false,
                     instance: instance || {},
                     errors: {},
                     message: message)
    end

    # Create a success response object.
    # Returns:
    #   - success: true.
    #   - instance: the passed-in instance. Can be an empty Hash.
    #   - errors: an empty hash.
    #   - message: the passed-in message.
    #
    #
    # @param message [String] the informational messages.
    # @param instance [nil, Object] the relevant instance.
    # @return [OpenStruct] the response object.
    def success_response(message, instance = nil)
      OpenStruct.new(success: true,
                     instance: instance || {},
                     errors: {},
                     message: message)
    end
  end
end
