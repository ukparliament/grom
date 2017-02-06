require_relative '../spec_helper'
require_relative '../fixtures/reader_stubs'

describe Grom::Builder do

  let(:empty_data) { StringIO.new(File.read('spec/fixtures/empty_data.nt')) }
  let(:reader) { Grom::Reader.new(empty_data) }
  let(:statements_by_subject) { STATEMENTS_BY_SUBJECT }
  let(:subjects_by_type) { SUBJECTS_BY_TYPE }
  let(:connections_by_subject) { CONNECTIONS_BY_SUBJECT }

  describe '#build_objects_by_subject' do
    subject {Grom::Builder.new(reader)}

    context 'data passed' do
      it 'creates all of the objects for each subject' do
        reader.instance_variable_set(:@statements_by_subject, statements_by_subject)
        reader.instance_variable_set(:@subjects_by_type, subjects_by_type)
        writer = subject.build_objects_by_subject
        expect(writer.instance_variable_get(:@objects).size).to eq(6)
      end
    end
  end

  describe '#link_objects' do
    let(:data) { StringIO.new(File.read('spec/fixtures/people_members_current.nt')) }
    let(:reader) { Grom::Reader.new(data) }
    subject { Grom::Builder.new(reader) }

    # before(:each) do
    #   reader.instance_variable_set(:@statements_by_subject, statements_by_subject)
    #   reader.instance_variable_set(:@subjects_by_type, subjects_by_type)
    #   reader.instance_variable_set(:@connections_by_subject, connections_by_subject)
    # end

    context 'data passed' do
      it 'links together related objects' do
        writer  = subject.build_objects_by_subject.link_objects
        objects = writer.instance_variable_get(:@objects)
        # p objects.first
        expect(objects.first.personHasSitting.first.sittingHasHouse.first.type).to eq('http://id.ukpds.org/schema/House')
      end
    end

    context 'empty @objects_by_subject data' do
      it 'rescues the exception caused by @objects_by_subject being empty' do
        writer = subject.build_objects_by_subject
        writer.instance_variable_set(:@objects_by_subject, {})
        expect { writer.link_objects }.to raise_error(NoMethodError)
      end
    end
  end

end