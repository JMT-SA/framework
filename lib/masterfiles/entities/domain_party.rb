require 'delegate'
class DomainParty < SimpleDelegator
  attr_accessor :roles

  def initialize(party)
    super(party)
    @roles = []
    # @party
  end

  def id
    party_id
  end

  # def organization?
  #   party_type == 'O'
  # end

  def role_list
    roles.map(&:name).join('; ')
    # roles.active.map(&:name).join('; ')
  end

  def name
    (short_description rescue nil) ? short_description : [title, first_name, surname].join(' ')
  end
end
