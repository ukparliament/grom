PERSON_ONE_HASH = { people: [
    { id: '1',
      name: 'Member1'
    }
] }

PEOPLE_JSON_LD = "{\"@graph\":[{\"@id\":\"http://id.example.com/1\",\"http://id.example.com/schema/dateOfBirth\":{\"@value\":\"1947-06-29\",\"@type\":\"http://www.w3.org/2001/XMLSchema#date\"},\"http://id.example.com/schema/forename\":\"Daenerys\",\"http://id.example.com/schema/middleName\":\"Khaleesi\",\"http://id.example.com/schema/surname\":\"Targaryen\"},{\"@id\":\"http://id.example.com/2\",\"http://id.example.com/schema/dateOfBirth\":{\"@value\":\"1954-01-12\",\"@type\":\"http://www.w3.org/2001/XMLSchema#date\"},\"http://id.example.com/schema/forename\":\"Arya\",\"http://id.example.com/schema/middleName\":\"The Blind Girl\",\"http://id.example.com/schema/surname\":\"Stark\"}]}"

PERSON_ONE_TTL = "<http://id.example.com/1> <http://id.example.com/schema/forename> \"Daenerys\" .\n <http://id.example.com/1> <http://id.example.com/schema/surname> \"Targaryen\" .\n <http://id.example.com/1> <http://id.example.com/schema/middleName> \"Khaleesi\" .\n <http://id.example.com/1> <http://id.example.com/schema/dateOfBirth> \"1947-06-29\"^^<http://www.w3.org/2001/XMLSchema#date> .\n <http://id.example.com/1> <http://id.example.com/schema/gender> <http://id.example.com/schema/Female> .\n"
PEOPLE_TTL = "<http://id.example.com/1> <http://id.example.com/schema/forename> \"Daenerys\" .\n <http://id.example.com/1> <http://id.example.com/schema/surname> \"Targaryen\" .\n <http://id.example.com/1> <http://id.example.com/schema/middleName> \"Khaleesi\" .\n <http://id.example.com/1> <http://id.example.com/schema/dateOfBirth> \"1947-06-29\"^^<http://www.w3.org/2001/XMLSchema#date> .\n <http://id.example.com/1> <http://id.example.com/schema/gender> <http://id.example.com/schema/Female> .\n <http://id.example.com/2> <http://id.example.com/schema/forename> \"Arya\" .\n <http://id.example.com/2> <http://id.example.com/schema/surname> \"Stark\" .\n <http://id.example.com/2> <http://id.example.com/schema/middleName> \"The Blind Girl\" .\n <http://id.example.com/2> <http://id.example.com/schema/dateOfBirth> \"1954-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n <http://id.example.com/2> <http://id.example.com/schema/gender> <http://id.example.com/schema/Female> .\n "
PERSON_TWO_TTL = "<http://id.example.com/2> <http://id.example.com/schema/forename> \"Arya\" .\n <http://id.example.com/2> <http://id.example.com/schema/surname> \"Stark\" .\n <http://id.example.com/2> <http://id.example.com/schema/middleName> \"The Blind Girl\" .\n <http://id.example.com/2> <http://id.example.com/schema/dateOfBirth> \"1954-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n <http://id.example.com/2> <http://id.example.com/schema/gender> <http://id.example.com/schema/Female> .\n"

PEOPLE_GRAPH = RDF::Graph.new
RDF::NTriples::Reader.new(PEOPLE_TTL) do |reader|
    reader.each_statement do |statement|
        PEOPLE_GRAPH << statement
    end
end

PERSON_ONE_GRAPH = RDF::Graph.new
RDF::NTriples::Reader.new(PERSON_ONE_TTL) do |reader|
    reader.each_statement do |statement|
        PERSON_ONE_GRAPH << statement
    end
end

PERSON_TWO_GRAPH = RDF::Graph.new
RDF::NTriples::Reader.new(PERSON_TWO_TTL) do |reader|
    reader.each_statement do |statement|
        PERSON_TWO_GRAPH << statement
    end
end

PEOPLE_HASH = [
    { forename: 'Daenerys',
      surname: 'Targaryen',
      middleName: 'Khaleesi',
      dateOfBirth: '1947-06-29',
      id: '1',
      graph: PERSON_ONE_GRAPH
    },
    { forename: 'Arya',
      surname: 'Stark',
      middleName: 'The Blind Girl',
      dateOfBirth: '1954-01-12',
      id: '2',
      graph: PERSON_TWO_GRAPH
    }
]


ONE_STATEMENT_STUB = RDF::Statement.new(RDF::URI.new("http://id.example.com/1"), RDF::URI.new("http://id.example.com/schema/forename"), 'Daenerys')

PARTY_ONE_TTL_OLD = "<http://id.example.com/81> <http://id.example.com/schema/partyName> \"Liberal Democrat\" .\n"
PARTY_ONE_TTL = "@prefix example: <http://id.example.com/schema/> .\n <http://id.example.com/81> example:partyName \"Liberal Democrat\" .\n"
PARTY_ONE_GRAPH = RDF::Graph.new
RDF::NTriples::Reader.new(PARTY_ONE_TTL_OLD) do |reader|
    reader.each_statement do |statement|
        PARTY_ONE_GRAPH << statement
    end
end

PARTY_AND_PARTY_MEMBERSHIP_ONE_TTL = "<http://id.example.com/23> <http://id.example.com/schema/partyName> \"Targaryens\" .\n <http://id.example.com/23> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyParty> .\n <http://id.example.com/25> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyPartyMembership> .\n <http://id.example.com/25> <http://id.example.com/schema/partyMembershipHasParty> <http://id.example.com/23> .\n <http://id.example.com/25> <http://id.example.com/schema/partyMembershipEndDate> \"1954-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n <http://id.example.com/25> <http://id.example.com/schema/partyMembershipStartDate> \"1953-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n <http://id.example.com/26> <http://id.example.com/schema/partyName> \"Dothrakis\" .\n <http://id.example.com/26> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyParty> .\n <http://id.example.com/27> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyPartyMembership> .\n <http://id.example.com/27> <http://id.example.com/schema/partyMembershipHasParty> <http://id.example.com/26> .\n <http://id.example.com/27> <http://id.example.com/schema/partyMembershipEndDate> \"1955-03-11\"^^<http://www.w3.org/2001/XMLSchema#date> .\n <http://id.example.com/27> <http://id.example.com/schema/partyMembershipStartDate> \"1954-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n"
PARTY_AND_PARTY_MEMBERSHIP_ONE_GRAPH = RDF::Graph.new
RDF::NTriples::Reader.new(PARTY_AND_PARTY_MEMBERSHIP_ONE_TTL) do |reader|
    reader.each_statement do |statement|
        PARTY_AND_PARTY_MEMBERSHIP_ONE_GRAPH << statement
    end
end

CONTACT_POINT_TTL = "<http://id.example.com/123> <http://id.example.com/postalCode> \"SW1A 0AA\" .\n <http://id.example.com/123> <http://id.example.com/email> \"daenerys@khaleesi.com\" .\n <http://id.example.com/123> <http://id.example.com/streetAddress> \"House of Commons\" .\n <http://id.example.com/123> <http://id.example.com/addressLocality> \"London\" .\n <http://id.example.com/123> <http://id.example.com/telephone> \"020 7555 5555\" .\n"

PARTY_MEMBERSHIP_TTL = "<http://id.example.com/25> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyPartyMembership> .\n <http://id.example.com/25> <http://id.example.com/schema/partyMembershipHasParty> <http://id.example.com/23> .\n <http://id.example.com/25> <http://id.example.com/schema/partyMembershipEndDate> \"1954-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n <http://id.example.com/25> <http://id.example.com/schema/partyMembershipStartDate> \"1953-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n"

PARTY_MEMBERSHIP_GRAPH = RDF::Graph.new
RDF::NTriples::Reader.new(PARTY_MEMBERSHIP_TTL) do |reader|
    reader.each_statement do |statement|
        PARTY_MEMBERSHIP_GRAPH << statement
    end
end

BLANK_PARTY_MEMBERSHIP_TTL_BY_PARTY = "<http://id.example.com/23> <http://id.example.com/schema/partyName> \"Targaryens\" .\n <http://id.example.com/23> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyParty> .\n _:node123 <http://id.example.com/schema/connect> <http://id.example.com/23> .\n _:node123 <http://id.example.com/schema/objectId> <http://id.example.com/42> .\n _:node123 <http://id.example.com/schema/partyMembershipEndDate> \"1954-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n _:node123 <http://id.example.com/schema/partyMembershipStartDate> \"1953-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n <http://id.example.com/26> <http://id.example.com/schema/partyName> \"Dothrakis\" .\n <http://id.example.com/26> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyParty> .\n _:node124 <http://id.example.com/schema/connect> <http://id.example.com/26> . \n _:node124 <http://id.example.com/schema/objectId> <http://id.example.com/43> . \n _:node124 <http://id.example.com/schema/partyMembershipEndDate> \"1955-03-11\"^^<http://www.w3.org/2001/XMLSchema#date> .\n _:node124 <http://id.example.com/schema/partyMembershipStartDate> \"1954-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n"

NO_TYPE_PARTY_MEMBERSHIP_TTL = "<http://id.example.com/25> <http://id.example.com/schema/partyMembershipEndDate> \"1954-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n <http://id.example.com/25> <http://id.example.com/schema/partyMembershipStartDate> \"1953-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n"

NO_TYPE_PARTY_MEMBERSHIP_GRAPH = RDF::Graph.new
RDF::NTriples::Reader.new(NO_TYPE_PARTY_MEMBERSHIP_TTL) do |reader|
    reader.each_statement do |statement|
        NO_TYPE_PARTY_MEMBERSHIP_GRAPH << statement
    end
end

CAT_ONE_TTL = "<http://id.example.com/123> <http://id.example.com/schema/name> \"Bob\" .\n"

DOGS_TTL = "<http://id.example.com/1863> <http://id.example.com/schema/name> \"B'uddy\" .\n <http://id.example.com/1866> <http://id.example.com/schema/name> \"F'ido\" .\n"
BUDDY_TTL = "<http://id.example.com/1863> <http://id.example.com/schema/name> \"B'uddy\" .\n"

BUDDY_GRAPH = RDF::Graph.new
RDF::NTriples::Reader.new(BUDDY_TTL) do |reader|
  reader.each_statement do |statement|
    BUDDY_GRAPH << statement
  end
end


BLANK_PARTY_MEMBERSHIPS_TTL = "<http://id.example.com/1> <http://id.example.com/schema/forename> \"Daenerys\" .\n <http://id.example.com/1> <http://id.example.com/schema/surname> \"Targaryen\" .\n <http://id.example.com/1> <http://id.example.com/schema/middleName> \"Khaleesi\" .\n _:node1504 <http://id.example.com/schema/connect> <http://id.example.com/1>.\n _:node1504 <http://id.example.com/schema/objectId> <http://id.example.com/42>.\n _:node1504 <http://id.example.com/schema/partyMembershipEndDate> \"1954-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n _:node1504 <http://id.example.com/schema/partyMembershipStartDate> \"1944-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n _:node1503 <http://id.example.com/schema/connect> <http://id.example.com/1>.\n _:node1503 <http://id.example.com/schema/objectId> <http://id.example.com/43>.\n _:node1503 <http://id.example.com/schema/partyMembershipEndDate> \"1959-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n _:node1503 <http://id.example.com/schema/partyMembershipStartDate> \"1948-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n"
BLANK_PARTY_MEMBERSHIPS_GRAPH = RDF::Graph.new
RDF::NTriples::Reader.new(BLANK_PARTY_MEMBERSHIPS_TTL) do |reader|
    reader.each_statement do |statement|
        BLANK_PARTY_MEMBERSHIPS_GRAPH << statement
    end
end

PERSON_ONE_NAMES_TTL = "<http://id.example.com/1> <http://id.example.com/schema/forename> \"Daenerys\" .\n <http://id.example.com/1> <http://id.example.com/schema/surname> \"Targaryen\" .\n <http://id.example.com/1> <http://id.example.com/schema/middleName> \"Khaleesi\" .\n"
PERSON_ONE_NAMES_GRAPH = RDF::Graph.new
RDF::NTriples::Reader.new(PERSON_ONE_NAMES_TTL) do |reader|
    reader.each_statement do |statement|
        PERSON_ONE_NAMES_GRAPH << statement
    end
end

BLANK_PARTY_MEMBERSHIPS_HASH = {
    :associated_class_hash => {
        "1"=>{:id=>"1", :graph=>PERSON_ONE_NAMES_GRAPH, :surname=>"Targaryen", :middleName=>"Khaleesi", :forename=>"Daenerys"}
    },
    :through_class_hash => {
        "_:node1504"=>{:associated_object_id=>"1", :partyMembershipEndDate=>"1954-01-12", :partyMembershipStartDate=>"1944-01-12", :id=>"42"},
        "_:node1503"=>{:associated_object_id=>"1", :partyMembershipEndDate=>"1959-01-12", :partyMembershipStartDate=>"1948-01-12", :id=>"43"}
    }
}

PEOPLE_AND_STUFF_TTL = "<http://id.example.com/1> <http://id.example.com/schema/forename> \"Daenerys\" .\n <http://id.example.com/1> <http://id.example.com/schema/surname> \"Targaryen\" .\n <http://id.example.com/1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyPerson> .\n <http://id.example.com/2> <http://id.example.com/schema/forename> \"Arya\" .\n <http://id.example.com/2> <http://id.example.com/schema/surname> \"Stark\" .\n  <http://id.example.com/2> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyPerson> .\n <http://id.example.com/81> <http://id.example.com/schema/partyName> \"Liberal Democrat\" .\n <http://id.example.com/81> <http://id.example.com/schema/connect>  <http://id.example.com/1> .\n <http://id.example.com/81> <http://id.example.com/schema/connect>  <http://id.example.com/2> .\n  <http://id.example.com/81> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyParty> .\n"

PERSON_AND_STUFF_TTL = "<http://id.example.com/1> <http://id.example.com/schema/forename> \"Daenerys\" .\n <http://id.example.com/1> <http://id.example.com/schema/surname> \"Targaryen\" .\n <http://id.example.com/1> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyPerson> .\n <http://id.example.com/81> <http://id.example.com/schema/partyName> \"Liberal Democrat\" .\n <http://id.example.com/81> <http://id.example.com/schema/connect>  <http://id.example.com/1> .\n <http://id.example.com/81> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyParty> .\n _:node1504 <http://id.example.com/schema/connect> <http://id.example.com/81>.\n _:node1504 <http://id.example.com/schema/objectId> <http://id.example.com/42>.\n _:node1504 <http://id.example.com/schema/partyMembershipEndDate> \"1954-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n _:node1504 <http://id.example.com/schema/partyMembershipStartDate> \"1944-01-12\"^^<http://www.w3.org/2001/XMLSchema#date> .\n _:node1504 <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://id.example.com/schema/DummyPartyMembership> .\n"
