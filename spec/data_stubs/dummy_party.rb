class DummyParty < Grom::Base

  has_many_through :dummy_members, via: :dummy_party_memberships

  def self.property_translator
    {
        id: 'id',
        partyName: 'name'
    }
  end
end