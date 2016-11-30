require 'spec_helper'

describe Grom::GraphMapper do
  let(:extended_class) { Class.new { extend Grom::GraphMapper } }

  describe '#create_graph_from_ttl' do
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

  describe '#convert_to_ttl' do
    it 'should return a string of ttl given a graph' do
      expect(extended_class.convert_to_ttl(PARTY_ONE_GRAPH)).to eq PARTY_ONE_TTL
    end
  end

  describe '#statements_mapper_by_subject' do
    it 'should return a hash with the mapped predicates and the respective objects from a graph' do
      arya = extended_class.statements_mapper_by_subject(PEOPLE_GRAPH).select{ |o| o[:id] == '2' }.first
      expect(arya[:forename]).to eq 'Arya'
      surname_pattern = RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/surname"), :object)
      expect(arya[:graph].query(surname_pattern).first_object.to_s).to eq 'Stark'
    end
  end

  describe '#get_object_and_predicate' do
    it 'should should return a hash with predicate and object, given an RDF statement' do
      expect(extended_class.get_object_and_predicate(ONE_STATEMENT_STUB)).to eq({ :forename => 'Daenerys' })
    end
  end

  describe '#through_split_graph' do
    let(:surname_pattern) { RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/surname"), :object) }
    let(:forename_pattern) { RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/forename"), :object) }

    it 'should return a hash with two hashes, associated_class_hash and through_class_hash' do
      hash = extended_class.through_split_graph(BLANK_PARTY_MEMBERSHIPS_GRAPH)
      person = hash[:associated_class_hash].values.first
      party_membership = hash[:through_class_hash].values.select{ |h| h[:id] == '42' }.first
      expect(person[:forename]).to eq 'Daenerys'
      expect(person[:surname]).to eq 'Targaryen'
      expect(person[:graph].query(forename_pattern).first_object.to_s).to eq 'Daenerys'
      expect(person[:graph].query(surname_pattern).first_object.to_s).to eq 'Targaryen'
      expect(party_membership[:partyMembershipStartDate]).to eq '1944-01-12'
      expect(party_membership[:partyMembershipEndDate]).to eq '1954-01-12'
      expect(party_membership[:associated_object_id]).to eq '1'
    end
  end
end