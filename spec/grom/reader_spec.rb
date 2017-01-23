require_relative '../spec_helper'

describe Grom::Reader do
  let(:data) { StringIO.new(File.read('spec/fixtures/people_members_current.nt')) }
  let(:empty_data) { StringIO.new(File.read('spec/fixtures/empty_data.nt')) }

  subject { Grom::Reader.new(data) }

  describe '#initialize' do
    it 'stores data into @data' do
      expect(subject.instance_variable_get(:@data)).to eq(data)
    end

    it 'returns an array of the built objects' do
      expect(subject.objects.size).to eq(14)
    end
  end

  describe '#create_hashes' do
    it 'populates @statements_by_subject' do
      reader = subject.read_data

      expect(reader.instance_variable_get(:@statements_by_subject).size).to eq(14)
    end

    it 'populates @subjects_by_type' do
      reader = subject.read_data

      expect(reader.instance_variable_get(:@subjects_by_type).size).to eq(6)
    end

    it 'populates @connections_by_subject' do
      reader = subject.read_data

      expect(reader.instance_variable_get(:@connections_by_subject).size).to eq(11)
    end
  end
end
