require File.join(File.expand_path('../../../../../test', __FILE__), 'test_helper')

class TestOrganizationInteractor < Minitest::Test

  def test_nothing
    x = OrganizationInteractor.new.create_organization_party
    p x
    assert true
  end

  # it "creates an organization party"
  # it "creates a person party"

  # it "updates an organization party"
  # it "updates a person party"

  # it "deletes an organization party"
  # it "deletes a person party"

  # it "returns an organization party"
  # it "returns a person party"

  # it "returns all parties"
  # it "returns all organization parties"
  # it "returns all person parties"

  # it "creates a role"
  # it "returns all roles"

  # it "creates an address type"
  # it "returns all address types"

  # it "creates a contact method"
  # it "returns all contact methods"

end