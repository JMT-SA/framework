require 'delegate'
class DomainParty < SimpleDelegator
  attr_accessor :roles

  def initialize(party)
    super(party)
    @roles = []
    # @addresses
    # @contact_methods
  end

  def role_list
    roles.map(&:name).join('; ')
  end

  def name
    (short_description rescue nil) ? short_description : [title, first_name, surname].join(' ')
  end
end
