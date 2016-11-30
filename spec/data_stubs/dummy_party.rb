class DummyParty < Grom::Base

  # apples :dummy_members, via: :dummy_party_memberships

  def self.property_translator
    {
        id: 'id',
        partyName: 'name'
    }
  end
end