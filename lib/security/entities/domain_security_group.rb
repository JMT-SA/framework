# frozen_string_literal: true

require 'delegate'

module SecurityApp
  class DomainSecurityGroup < SimpleDelegator
    attr_accessor :security_permissions

    def initialize(security_group)
      super(security_group)
      @security_permissions = []
    end

    def permission_list
      security_permissions.map(&:security_permission).join('; ')
    end
  end
end
