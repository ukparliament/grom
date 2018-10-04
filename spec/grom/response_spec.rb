require_relative '../spec_helper'

describe Grom::Response do
  let(:response_both_arguments) { described_class.new('objects', 'labels') }
  let(:response_no_labels) { described_class.new('objects') }

  describe '#initialize' do
    it 'stores labels into @labels' do
      expect(response_both_arguments.labels).to eq('labels')
    end

    it 'stores objects into @objects' do
      expect(response_both_arguments.objects).to eq('objects')
    end

    it 'has a default value of nil for labels' do
      expect(response_no_labels.labels).to be(nil)
    end
  end
end