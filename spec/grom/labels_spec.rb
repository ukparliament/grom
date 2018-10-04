require_relative '../spec_helper'

describe Grom::Labels do
  let(:labels) do
    { 'https://id.parliament.uk/schema/layingDate'      => ['laying date'],
      'https://id.parliament.uk/schema/personGivenName' => ['person given name'],
      'https://id.parliament.uk/schema/procedureName'   => ['procedure name']
    }
  end

  subject {described_class.new(labels)}

  describe '#initialize' do
    it 'sets an instance variable for the labels' do
      expect(subject.instance_variable_get(:@labels)).to eq(labels)
    end

    it 'should respond to size' do
      expect(subject).to respond_to(:size)
    end

    it 'should respond to each' do
      expect(subject).to respond_to(:each)
    end

    it 'should respond to select' do
      expect(subject).to respond_to(:select)
    end

    it 'should respond to select!' do
      expect(subject).to respond_to(:select!)
    end

    it 'should respond to length' do
      expect(subject).to respond_to(:length)
    end

    it 'should respond to empty?' do
      expect(subject).to respond_to(:empty?)
    end
  end

  describe '#fetch' do
    context 'the property has a label' do
      it 'returns the correct label' do
        expected_label = subject.fetch(:personGivenName, 'test')

        expect(expected_label).to eq('person given name')
      end
    end

    context 'the property does not have a label' do
      it 'returns the default value' do
        expected_label = subject.fetch(:personFamilyName, 'test')

        expect(expected_label).to eq('test')
      end
    end
  end
end