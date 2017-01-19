require_relative '../spec_helper'

describe Grom::Reader do
  let(:data) { StringIO.new(File.read('spec/fixtures/people_members_current.nt')) }

  subject { Grom::Reader.new(data) }

  describe '#initialize' do
    it 'stores data into @data' do
      expect(subject.instance_variable_get(:@data)).to eq(data)
    end
  end

  describe '#create_objects' do
    pending
  end

  describe '#create_hashes' do
    it 'populates @statements_by_subject' do
      reader = subject.create_hashes

      expect(reader.instance_variable_get(:@statements_by_subject).size).to eq(14)
    end

    it 'populates @subjects_by_type' do
      reader = subject.create_hashes

      expect(reader.instance_variable_get(:@subjects_by_type).size).to eq(6)
    end

    it 'populates @connections_by_subject' do
      reader = subject.create_hashes

      expect(reader.instance_variable_get(:@connections_by_subject).size).to eq(11)
    end
  end

  describe '#create_objects_by_subject' do
    subject { Grom::Reader.new(data).create_hashes }

    it 'creates all of the objects for each subject' do
      expect(subject.create_objects_by_subject.size).to eq(14)
    end
  end

  describe 'self#get_id' do
    it 'strips a type correctly' do
      expect(Grom::Reader.get_id(RDF.type)).to eq('type')
    end

    it 'strips a uri correctly' do
      expect(Grom::Reader.get_id('http://google.com/12345-567-a910')).to eq('12345-567-a910')
    end

    it 'handles a nil value' do
      expect(Grom::Reader.get_id(nil)).to eq(nil)
    end

    it 'handles an empty string' do
      expect(Grom::Reader.get_id('')).to eq(nil)
    end

    it 'handles a non-string object' do
      expect(Grom::Reader.get_id(%w(a b c))).to eq(nil)
    end
  end
end
