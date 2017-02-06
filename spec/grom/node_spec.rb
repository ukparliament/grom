require_relative '../spec_helper'

describe Grom::Node do
  describe '#initialize' do
    context 'with statements' do
      let(:statements) do
        [
          RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF.type, 'Person'),
          RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/forename'), 'Jane'),
          RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/surname'), 'Smith')
        ]
      end

      subject { Grom::Node.new(statements) }

      context 'instance variables' do
        it 'sets @graph_id' do
          expect(subject.instance_variable_get(:@graph_id)).to eq('123')
        end

        it 'sets @type' do
          expect(subject.instance_variable_get(:@type)).to eq('Person')
        end

        it 'sets @forename' do
          expect(subject.instance_variable_get(:@forename)).to eq('Jane')
        end

        it 'sets @surname' do
          expect(subject.instance_variable_get(:@surname)).to eq('Smith')
        end
      end

      context 'methods' do
        it 'responds to #graph_id' do
          expect{ subject.method(:graph_id) }.not_to raise_error
          expect(subject.graph_id).to eq('123')
        end

        it 'responds to #type' do
          expect{ subject.method(:type) }.not_to raise_error
          expect(subject.type).to eq('Person')
        end

        it 'responds to #forename' do
          expect{ subject.method(:forename) }.not_to raise_error
          expect(subject.forename).to eq('Jane')
        end

        it 'responds to #surname' do
          expect{ subject.method(:surname) }.not_to raise_error
          expect(subject.surname).to eq('Smith')
        end

        it 'does not respond to #something_random' do
          expect{ subject.method(:something_random) }.to raise_error(NameError, 'undefined method `something_random\' for class `Grom::Node\'')
          expect{ subject.something_random }.to raise_error(NoMethodError)
        end
      end
    end

    context 'without statements' do
      it 'raises an ArgumentError' do
        expect{ Grom::Node.new }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
      end
    end
  end
end