require 'spec_helper'

describe Grom::GraphMapper do
  let(:extended_class) { Class.new { extend Grom::GraphMapper } }

  xdescribe '#create_graph_from_ttl' do
    it 'should create an RDF graph given ttl data in a string format' do
      expect(extended_class.create_graph_from_ttl(PERSON_ONE_TTL).first).to eq PERSON_ONE_GRAPH.first
    end

    it 'should return an RDF graph when there are single quotes in the ttl data' do
      expect(extended_class.create_graph_from_ttl(BUDDY_TTL)).to eq BUDDY_GRAPH
    end
  end

  describe '#get_id' do
    it 'should return the id if given a uri' do
      expect(extended_class.get_id(RDF::URI.new('http://id.example.com/123'))).to eq '123'
    end

    it 'should return "type" if given an RDF.type uri' do
      expect(extended_class.get_id(RDF.type)).to eq 'type'
    end
  end

  xdescribe '#convert_to_ttl' do
    it 'should return a string of ttl given a graph' do
      expect(extended_class.convert_to_ttl(PARTY_ONE_GRAPH)).to eq PARTY_ONE_TTL
    end
  end

  describe '#statements_mapper' do
    it 'should return a hash with the mapped predicates and the respective objects from a graph' do
      arya = extended_class.statements_mapper(PEOPLE_GRAPH).select{ |o| o[:id] == '2' }.first
      expect(arya[:forename]).to eq 'Arya'
      surname_pattern = RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/surname"), :object)
      expect(arya[:graph].query(surname_pattern).first_object.to_s).to eq 'Stark'
    end
  end

end