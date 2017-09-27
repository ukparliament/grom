require_relative '../spec_helper'

describe Grom::Reader do
  let(:data) { StringIO.new(File.read('spec/fixtures/people_members_current.nt')) }
  let(:single_data) { StringIO.new(File.read('spec/fixtures/single_person_current.nt')) }
  let(:single_data_multiple_sites) { StringIO.new(File.read('spec/fixtures/single_person_current_multiple_sites.nt')) }
  let(:empty_data) { StringIO.new(File.read('spec/fixtures/empty_data.nt')) }

  subject { Grom::Reader.new(data) }

  describe '#initialize' do
    it 'stores data into @data' do
      expect(subject.instance_variable_get(:@data)).to eq(data)
    end

    it 'returns an array of the built objects' do
      expect(subject.objects.size).to eq(14)
    end

    context 'when data contains uri objects' do
      context 'a single website' do
        subject { Grom::Reader.new(single_data) }

        it 'stores uri values as expected' do
          expect(subject.objects.first.personHasPersonWebLink).to eq('http://example.com/')
        end
      end

      context 'multiple websites' do
        subject { Grom::Reader.new(single_data_multiple_sites) }

        it 'stores uri values as expected' do
          expect(subject.objects.first.personHasPersonWebLink).to eq(['http://example.com/', 'http://example-2.com/'])
        end
      end
    end
  end

  describe '#create_hashes' do
    it 'populates @statements_by_subject' do
      reader = subject.read_data

      expect(reader.instance_variable_get(:@statements_by_subject).size).to eq(14)
    end

    it 'populates @edges_by_subject' do
      reader = subject.read_data

      expect(reader.instance_variable_get(:@edges_by_subject).size).to eq(14)
    end
  end
end
