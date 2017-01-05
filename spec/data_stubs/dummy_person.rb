class DummyPerson < Grom::Base
  has_many_through :dummy_parties, via: :dummy_party_memberships
  has_many :dummy_contact_points
  has_one :dummy_cat

  def self.property_translator
    {
        id: 'id',
        forename: 'forename',
        surname: 'surname',
        middleName: 'middle_name',
        dateOfBirth: 'date_of_birth',
        gender: 'gender',
        type: 'type'
    }
  end

  def self.has_many_associations
    ["dummy_parties", "dummy_party_memberships", "dummy_cats"]
  end

  def sittings
    @sittings
  end

  def sittings=(arr)
    @sittings = arr
  end
end