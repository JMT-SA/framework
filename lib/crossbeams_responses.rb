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
    # validation results must either be a Dry::Validation::Result or a Hash or OpenStruct.
    # The Hash should have attributes for the object in error and a key `:messages`.
    # `:messages` must be in the same format as Dry::Validation::Result.messages.
    # i.e `messages: { field1: ['error', 'another error'], field2: ['an err'] }`
    #
    # @param validation_results [Hash, Dry::Validation::Result, OpenStruct] the validation object and messages.
    # @return [OpenStruct] the response object.
    def validation_failed_response(validation_results)
      # Dry::Schema::Result / Dry::Validation::Result
      from_dry = validation_results.respond_to?(:failure?)
      OpenStruct.new(success: false,
                     # instance: validation_results.is_a?(Dry::Validation::Result) ? validation_results.to_h : validation_results.to_h.reject { |k, _| k == :messages },
                     # errors: validation_results.is_a?(Hash) ? validation_results[:messages] : validation_results.messages,
                     instance: from_dry ? validation_results.to_h : validation_results.to_h.reject { |k, _| k == :messages },
                     errors: from_dry ? validation_results.errors.to_h : validation_results[:messages],
                     message: 'Validation error')
    end

    # Alias for validation_failed_response that shows only error messages (no instance).
    # This is simpler to call if the instance is not required.
    # Returns:
    #   - success: false.
    #   - instance: an empty Hash.
    #   - errors: the error messages.
    #   - message: "Validation error".
    #
    # e.g. validation_failed_message_response(name: ['required', 'too short'], email: ['required'])
    #
    # @param messages [Hash] the validation error messages.
    # @return [OpenStruct] the response object.
    def validation_failed_message_response(messages)
      validation_failed_response(messages: messages)
    end

    # Create a response object with validation errors from more than one source.
    # Returns:
    #   - success: false.
    #   - instance: a Hash of the objec(s) that failed validation.
    #   - errors: the error messages.
    #   - message: "Validation error".
    #
    # validation results must either be an array of Dry::Validation::Result or Hash.
    # A Hash should have attributes for the object in error and a key `:messages`.
    # `:messages` must be in the same format as Dry::Validation::Result.messages.
    # i.e `messages: { field1: ['error', 'another error'], field2: ['an err'] }`
    #
    # @param validation_results [Array(Hash, Dry::Validation::Result)] the validation objects and messages.
    # @return [OpenStruct] the response object.
    def mixed_validation_failed_response(*validation_results)
      errs = {}
      instance = {}
      validation_results.each do |vr|
        # errs.merge!(vr.is_a?(Hash) ? vr[:messages] : vr.messages)
        # errs.merge!(vr.is_a?(Hash) ? vr[:messages] : vr.errors.to_h)
        errs.merge!(vr.respond_to?(:failure?) ? vr.errors.to_h : vr[:messages])
        instance.merge!(vr.to_h)
      end
      OpenStruct.new(success: false,
                     instance: instance.reject { |k, _| k == :messages },
                     errors: errs,
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

    # Retrurn a basic success response with message 'ok'
    # - use this when the message does not matter.
    #
    # @return [OpenStruct] the success response object.
    def ok_response
      success_response('ok')
    end

    # Take a Crossbeams::Response and present it as an error message.
    # For a validation error, the errors are listed in the returned message.
    #
    # @param res [Crossbeams::Response] the response object.
    # @return [String] the formatted message.
    def unwrap_failed_response(res)
      if res.errors.empty?
        res.message
      else
        "#{res.message} - #{res.errors.map { |fld, errs| "#{fld} #{unwrap_errors(errs)}" }.join('; ')}"
      end
    end

    # Take validation errors and unwrap Array or Hash.
    # Do not call directly. Use +unwrap_failed_response+
    #
    # @param errs [array,hash] the validation errors for a particular field.
    # @return [string] the list of validation errors for the field.
    def unwrap_errors(errs)
      return errs.join(', ') if errs.is_a?(Array)

      errs.group_by { |_, v| v }.map { |k, v| ": #{v.length} item#{v.length == 1 ? '' : 's'} #{k.join(', ')}" }.join(', ')
    end
  end
end
