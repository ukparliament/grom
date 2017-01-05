class DummyPartyMembership < Grom::Base
  def self.property_translator
    {
        id: 'id',
        partyMembershipStartDate: 'start_date',
        partyMembershipEndDate: 'end_date'
    }
  end

  def self.has_one
    ["dummy_party"]
  end
end