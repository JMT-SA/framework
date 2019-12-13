# frozen_string_literal: true

module PackMaterialApp
  class CompleteSalesOrder < BaseService
    attr_reader :id, :repo

    def initialize(id)
      @id = id
      @repo = SalesRepo.new
    end

    def call
      repo.do_work
      success_response('CompleteSalesOrder was successful')
    end
  end
end
