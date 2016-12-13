require 'spec_helper'

describe Grom::GraphMapper do
  let(:extended_class) { Class.new { extend Grom::GraphMapper } }

  describe '#get_id' do
    it 'should return the id if given a uri' do
      expect(extended_class.get_id(RDF::URI.new('http://id.example.com/123'))).to eq '123'
    end

    it 'should return "type" if given an RDF.type uri' do
      expect(extended_class.get_id(RDF.type)).to eq 'type'
    end
  end

  xdescribe '#statements_mapper' do
    it 'should return a hash with the mapped predicates and the respective objects from a graph' do
      arya = extended_class.statements_mapper(PEOPLE_GRAPH).select{ |o| o[:id] == '2' }.first
      expect(arya[:forename]).to eq 'Arya'
      surname_pattern = RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/surname"), :object)
      expect(arya[:graph].query(surname_pattern).first_object.to_s).to eq 'Stark'
    end
  end

end