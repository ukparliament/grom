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

  describe '#json_ld' do
    it 'should return a json_ld representation of the given objects' do
      json_ld_string = '{"@context"=>"{\"xsd\":\"http://www.w3.org/2001/XMLSchema#\",\"DummySquirrel\":\"http://id.example.com/schema/DummySquirrel\",\"name\":\"http://id.example.com/schema/name\",\"date_of_birth\":{\"@id\":\"http://id.example.com/schema/date_of_birth\",\"@type\":\"xsd:integer\"}}", "@graph"=>[{"@id"=>"http://id.example.com/927", "name"=>"Chip", "date_of_birth"=>"1960-01-01", "@type"=>"DummySquirrel"}, {"@id"=>"http://id.example.com/792", "name"=>"Dale", "date_of_birth"=>"1960-01-01", "@type"=>"DummySquirrel"}]}'
      squirrels = DummySquirrel.all
      json_ld = extended_class.json_ld(squirrels)
      expect(json_ld).to eq json_ld_string
    end
  end
end