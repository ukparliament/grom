require 'spec_helper'

describe Grom::Helpers do

  let(:extended_class) { Class.new { extend Grom::Helpers } }
  let(:dummy) { DummyPerson.find('1') }
  let(:surname_pattern) { RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/surname"), :object) }
  let(:forename_pattern) { RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/forename"), :object) }

  describe '#associations_url_builder' do
    it 'should return an endpoint when given a class and an associated class' do
      url = extended_class.associations_url_builder(dummy, "Party", {})
      expect(url).to eq "#{API_ENDPOINT}/dummy_people/1/parties.ttl"
    end

    it 'should return an endpoint when given a class, an associated class and an options hash with optional set' do
      url = extended_class.associations_url_builder(dummy, "Party", {optional: ["current"] })
      expect(url).to eq "#{API_ENDPOINT}/dummy_people/1/parties/current.ttl"
    end

    it 'should return an endpoint when given a class, an associated class and an options hash with single set to true' do
      url = extended_class.associations_url_builder(dummy, "Party", {single: true })
      expect(url).to eq "#{API_ENDPOINT}/dummy_people/1/party.ttl"
    end
  end

  describe '#find_base_url_builder' do
    it 'should return a url with the api_endpoint and the pluralized, underscored and downcased name of the class and an id when provided' do
      url = extended_class.find_base_url_builder("ContactPerson", "1")
      expect(url).to eq "#{API_ENDPOINT}/contact_people/1"
    end
  end

  describe '#all_base_url_builder' do
    it 'should return a url with the api_endpoint and the pluralized, underscored and downcased name of the class' do
      url = extended_class.all_base_url_builder("ContactPerson")
      expect(url).to eq "#{API_ENDPOINT}/contact_people"
    end

    it 'should return a url with the api_endpoint and the pluralized, underscored and downcased name of the class and given optionals' do
      url = extended_class.all_base_url_builder("ContactPerson", "members", "current")
      expect(url).to eq "#{API_ENDPOINT}/contact_people/members/current"
    end
  end

  describe '#create_class_name' do
    it 'should camelize, capitalize and singularize any plural underscore properties' do
      expect(extended_class.create_class_name('dummy_party_memberships')).to eq 'DummyPartyMembership'
    end
  end

  describe '#create_property_name' do
    it 'should underscore and downcase any singular class name' do
      expect(extended_class.create_property_name('DummyPerson')).to eq 'dummy_person'
    end
  end

  describe '#create_plural_property_name' do
    it 'should underscore, downcase and pluralize any singular class name' do
      expect(extended_class.create_plural_property_name('DummyPerson')).to eq 'dummy_people'
    end
  end

  describe '#collective_graph' do
    it 'should return the collective graph for the objects in the array' do
      dummy_people = DummyPerson.all
      collective_graph = extended_class.collective_graph(dummy_people)
      arya_surname_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/2"), RDF::URI.new("#{DATA_URI_PREFIX}/schema/surname"), :object)
      daenerys_surname_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/1"), RDF::URI.new("#{DATA_URI_PREFIX}/schema/surname"), :object)
      expect(collective_graph.query(arya_surname_pattern).first_object.to_s).to eq 'Stark'
      expect(collective_graph.query(daenerys_surname_pattern).first_object.to_s).to eq 'Targaryen'
    end
  end

  describe '#collective_has_many_graph' do
    it 'should return a graph that contains the owner and the associated objects' do
      collective_graph = extended_class.collective_has_many_graph(dummy, dummy.dummy_contact_points)
      email_pattern = RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/email"), :object)

      expect(collective_graph.query(forename_pattern).first_object.to_s).to eq 'Daenerys'
      expect(collective_graph.query(surname_pattern).first_object.to_s).to eq 'Targaryen'
      expect(collective_graph.query(email_pattern).first_object.to_s).to eq 'daenerys@khaleesi.com'
    end
  end

  xdescribe '#collective_through_graph' do

    let(:collective_through_graph) { extended_class.collective_through_graph(dummy, dummy.dummy_parties, :dummy_party_memberships) }

    it 'should return a graph that contains statements for the owner and the through objects' do
      expect(collective_through_graph.query(forename_pattern).first_object.to_s).to eq 'Daenerys'
      expect(collective_through_graph.query(surname_pattern).first_object.to_s).to eq 'Targaryen'
    end

    it 'should return a graph that contains statements for the associated objects and the connection statements with the through object' do
      party_one_type_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/23"), RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), :object)
      party_two_type_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/26"), RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), :object)
      party_one_name_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/23"), RDF::URI.new("#{DATA_URI_PREFIX}/schema/partyName"), :object)
      party_two_name_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/26"), RDF::URI.new("#{DATA_URI_PREFIX}/schema/partyName"), :object)
      party_one_connection_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/25"), RDF::URI.new("#{DATA_URI_PREFIX}/schema/partyMembershipHasParty"), :object)
      party_two_connection_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/27"), RDF::URI.new("#{DATA_URI_PREFIX}/schema/partyMembershipHasParty"), :object)

      expect(collective_through_graph.query(party_one_name_pattern).first_object.to_s).to eq 'Targaryens'
      expect(collective_through_graph.query(party_two_name_pattern).first_object.to_s).to eq 'Dothrakis'
      expect(collective_through_graph.query(party_one_type_pattern).first_object.to_s).to eq 'http://id.example.com/schema/DummyParty'
      expect(collective_through_graph.query(party_two_type_pattern).first_object.to_s).to eq 'http://id.example.com/schema/DummyParty'
      expect(collective_through_graph.query(party_one_connection_pattern).first_object.to_s).to eq 'http://id.example.com/23'
      expect(collective_through_graph.query(party_two_connection_pattern).first_object.to_s).to eq 'http://id.example.com/26'

    end

    it 'should return a graph that contains statements for the through objects' do
      party_one_membership_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/25"), RDF::URI.new("#{DATA_URI_PREFIX}/schema/partyMembershipEndDate"), :object)
      party_two_membership_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/27"), RDF::URI.new("#{DATA_URI_PREFIX}/schema/partyMembershipEndDate"), :object)
      party_membership_one_type_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/25"), RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), :object)
      party_membership_two_type_pattern = RDF::Query::Pattern.new(RDF::URI.new("http://id.example.com/27"), RDF::URI.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), :object)

      expect(collective_through_graph.query(party_membership_one_type_pattern).first_object.to_s).to eq 'http://id.example.com/schema/DummyPartyMembership'
      expect(collective_through_graph.query(party_membership_two_type_pattern).first_object.to_s).to eq 'http://id.example.com/schema/DummyPartyMembership'
      expect(collective_through_graph.query(party_one_membership_pattern).first_object.to_s).to eq '1954-01-12'
      expect(collective_through_graph.query(party_two_membership_pattern).first_object.to_s).to eq '1955-03-11'
    end
  end

  describe '#order_list' do
    let(:people) { [DummyPerson.new({ id: '3', surname: 'Targaryen', forename: 'Daenerys', graph: RDF::Graph.new }),
                    DummyPerson.new({ id: '2', surname: 'Stark', forename: 'Sansa', graph: RDF::Graph.new }),
                    DummyPerson.new({ id: '1', surname: 'Stark', forename: 'Arya', graph: RDF::Graph.new }),
                    DummyPerson.new({ id: '4', surname: 'Stark', forename: 'Bran', graph: RDF::Graph.new })] }
    let(:people_with_nil_property) { [DummyPerson.new({ id: '3', surname: 'Targaryen', forename: 'Daenerys', graph: RDF::Graph.new }),
                    DummyPerson.new({ id: '2', surname: 'Stark', forename: 'Sansa', graph: RDF::Graph.new }),
                    DummyPerson.new({ id: '5', surname: 'Williams', graph: RDF::Graph.new }),
                    DummyPerson.new({ id: '1', surname: 'Alexander', forename: 'Bob', graph: RDF::Graph.new }),
                    DummyPerson.new({ id: '6', surname: 'Stark', graph: RDF::Graph.new }),
                    DummyPerson.new({ id: '4', surname: 'Stark', forename: 'Bran', graph: RDF::Graph.new })] }
    it 'should take an array of objects and order them given one parameter' do
      ordered_people = extended_class.order_list(people, :forename)
      expect(ordered_people[0].forename).to eq 'Arya'
      expect(ordered_people[1].forename).to eq 'Bran'
      expect(ordered_people[2].forename).to eq 'Daenerys'
      expect(ordered_people[3].forename).to eq 'Sansa'
    end

    it 'should take an array of objects and order them given two parameters - a surname and forename' do
      ordered_people = extended_class.order_list(people, :surname, :forename)
      expect(ordered_people[0].forename).to eq 'Arya'
      expect(ordered_people[1].forename).to eq 'Bran'
      expect(ordered_people[2].forename).to eq 'Sansa'
      expect(ordered_people[3].forename).to eq 'Daenerys'
    end

    it 'should take an array of objects and order them given two parameters - a surname and id' do
      ordered_people = extended_class.order_list(people, :surname, :id)
      expect(ordered_people[0].forename).to eq 'Arya'
      expect(ordered_people[1].forename).to eq 'Sansa'
      expect(ordered_people[2].forename).to eq 'Bran'
      expect(ordered_people[3].forename).to eq 'Daenerys'
    end

    it 'should take an array of objects and order them given two parameters - a surname and forename - when one person has no forename' do
      ordered_people = extended_class.order_list(people_with_nil_property, :surname, :forename)
      expect(ordered_people[0].id).to eq '5'
      expect(ordered_people[1].id).to eq '6'
      expect(ordered_people[2].id).to eq '1'
      expect(ordered_people[3].id).to eq '4'
      expect(ordered_people[4].id).to eq '2'
      expect(ordered_people[5].id).to eq '3'
    end
  end

  describe '#order_list_by_through' do
    it 'should take an array of objects and order them by the given through property' do
      people = [DummyPerson.new({ id: '3', surname: 'Targaryen', forename: 'Daenerys', graph: RDF::Graph.new }),
                  DummyPerson.new({ id: '2', surname: 'Stark', forename: 'Sansa', graph: RDF::Graph.new })]
      people[0].sittings=([{ sittingStartDate: "2015-05-07" }, { sittingStartDate: "2005-05-03", sittingEndDate: "2000-03-01" }])
      people[1].sittings=([{ sittingStartDate: "2010-05-06", sittingEndDate: "2015-03-30" }])
      ordered_sittings = extended_class.order_list_by_through(people, :sittings, :sittingStartDate)

      expect(ordered_sittings[0][:sittingStartDate]).to eq "2005-05-03"
      expect(ordered_sittings[1][:sittingStartDate]).to eq "2010-05-06"
      expect(ordered_sittings[2][:sittingStartDate]).to eq "2015-05-07"
    end
  end

end