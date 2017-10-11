require 'delegate'
class DomainSecurityGroup < SimpleDelegator
  attr_accessor :security_permissions

  def initialize(security_group)
    super(security_group)
    @security_permissions = []
  end

  def permission_list
    security_permissions.map { |sp| sp.security_permission }.join('; ')
  end
end