module Crossbeams
  module Responses
    def validation_failed_response(validation_results)
      OpenStruct.new(success: false,
                     instance: {},
                     errors: validation_results.messages,
                     message: 'Validation error')
    end

    def failed_response(message, instance = nil)
      OpenStruct.new(success: false,
                     instance: instance,
                     errors: {},
                     message: message)
    end

    def success_response(message, instance = nil)
      OpenStruct.new(success: true,
                     instance: instance,
                     errors: {},
                     message: message)
    end
  end
end
