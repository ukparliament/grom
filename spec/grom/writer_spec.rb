require_relative '../spec_helper'
require_relative '../fixtures/reader_stubs'
require 'pry'

describe Grom::Writer do

  let(:empty_data) { StringIO.new(File.read('spec/fixtures/empty_data.nt')) }
  let(:reader) { Grom::Reader.new(empty_data) }
  let(:statements_by_subject) { STATEMENTS_BY_SUBJECT }
  let(:subjects_by_type) { SUBJECTS_BY_TYPE }
  let(:connections_by_subject) { CONNECTIONS_BY_SUBJECT }

  describe '#create_objects_by_subject' do
    subject {Grom::Writer.new(reader)}

    context 'data passed' do
      it 'creates all of the objects for each subject' do
        allow(reader).to receive(:statements_by_subject).and_return(statements_by_subject)
        allow(reader).to receive(:subjects_by_type).and_return(subjects_by_type)
        writer = subject.create_objects_by_subject

        expect(writer.instance_variable_get(:@objects).size).to eq(6)
      end
    end

    context 'empty data passed' do
      it 'rescues the exception caused by @statements_by_subject being empty' do
        allow(reader).to receive(:statements_by_subject).and_return({})

        expect { subject.create_objects_by_subject }.to raise_error(NoMethodError)
      end
    end
  end

  describe '#link_objects' do
    subject { Grom::Writer.new(reader) }

    before(:each) do
      allow(reader).to receive(:statements_by_subject).and_return(statements_by_subject)
      allow(reader).to receive(:subjects_by_type).and_return(subjects_by_type)
      allow(reader).to receive(:connections_by_subject).and_return(connections_by_subject)
    end

    context 'data passed' do
      it 'links together related objects' do
        writer  = subject.create_objects_by_subject.link_objects
        objects = writer.instance_variable_get(:@objects)
        expect(objects.first.sittings.first.houses.first.type).to eq('http://id.ukpds.org/schema/House')
      end
    end

    context 'empty @objects_by_subject data' do
      it 'rescues the exception caused by @objects_by_subject being empty' do
        writer = subject.create_objects_by_subject
        writer.instance_variable_set(:@objects_by_subject, {})
        # TODO: Look at replacing raise_exception - try to match specific error
        expect { writer.link_objects }.to raise_exception
      end
    end
  end

end