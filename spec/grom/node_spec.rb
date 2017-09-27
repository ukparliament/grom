require_relative '../spec_helper'

describe Grom::Node do
  let(:statements) do
    [
        RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF.type, 'Person'),
        RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/forename'), 'Jane'),
        RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/surname'), 'Smith')
    ]
    end

    let(:blank_node_statement) { [RDF::Statement.new(RDF::Node.new, RDF::URI.new('http://example.com/value'), 'A')] }

  subject { Grom::Node.new(statements) }

  describe '#initialize' do
    context 'with statements' do
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
    end

    context 'without statements' do
      it 'raises an ArgumentError' do
        expect{ Grom::Node.new }.to raise_error(ArgumentError, 'wrong number of arguments (given 0, expected 1)')
      end
    end
  end

  describe '#populate' do
    context 'single attribute' do
      it 'will populate attributes' do
        expect(subject.instance_variable_get(:@forename)).to be_a(String)
        expect(subject.instance_variable_get(:@forename)).to eq('Jane')
      end
    end

    context 'multiple attributes' do
      let(:multi_attribute_statements) do
        [
            RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF.type, 'Person'),
            RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/forename'), 'Jane'),
            RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/surname'), 'Smith'),
            RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF.type, 'Person'),
            RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/forename'), 'David'),
            RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/surname'), 'Davidson')
        ]
      end
      subject {Grom::Node.new(multi_attribute_statements)}

      it 'will populate arrays with both attributes' do
        expect(subject.instance_variable_get(:@forename)).to be_a(Array)
        expect(subject.instance_variable_get(:@forename)).to eq(['Jane', 'David'])
      end
    end

    context 'uri object' do
      let(:uri_object_statements) do
        [
            RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF.type, 'Person'),
            RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/forename'), 'Jane'),
            RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/surname'), 'Smith'),
            RDF::Statement.new(RDF::URI.new('http://example.com/123'), RDF::URI.new('http://example.com/website'), RDF::URI.new('http://example.com/'))
        ]
      end

      subject {Grom::Node.new(uri_object_statements)}

      it 'will populate URIs as strings' do
        expect(subject.instance_variable_get(:@website)).to be_a(String)
        expect(subject.instance_variable_get(:@website)).to eq('http://example.com/')
      end
    end
  end

  describe '#method_missing' do
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

  describe '#respond_to_missing?' do
    it 'responds to #graph_id' do
      expect(subject.respond_to?(:graph_id)).to be(true)
    end

    it 'responds to #type' do
      expect(subject.respond_to?(:type)).to be(true)
    end

    it 'responds to #forename' do
      expect(subject.respond_to?(:forename)).to be(true)
    end

    it 'responds to #surname' do
      expect(subject.respond_to?(:surname)).to be(true)
    end

    it 'does not respond to #something_random' do
      expect(subject.respond_to?(:something_random)).to be(false)
    end
  end

  describe '#blank?' do
    it 'returns true for a Grom::Node populated with blank nodes' do
      node = Grom::Node.new(blank_node_statement)

      expect(node.blank?).to be(true)
    end

    it 'returns false for a Grom::Node which is not a blank node' do
      expect(subject.blank?).to be(false)
    end
  end
end