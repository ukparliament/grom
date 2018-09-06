require_relative '../spec_helper'
require_relative '../fixtures/reader_stubs'

describe Grom::Builder do

  let(:empty_data) { StringIO.new(File.read('spec/fixtures/empty_data.nt')) }
  let(:reader) { Grom::Reader.new(empty_data) }
  let(:statements_by_subject) { STATEMENTS_BY_SUBJECT }
  let(:subjects_by_type) { SUBJECTS_BY_TYPE }
  let(:connections_by_subject) { CONNECTIONS_BY_SUBJECT }

  let(:reader_with_data) do
    local_reader = reader
    local_reader.instance_variable_set(:@statements_by_subject, statements_by_subject)
    local_reader.instance_variable_set(:@subjects_by_type, subjects_by_type)

    local_reader
  end

  subject(:builder_without_decorators) { Grom::Builder.new(reader_with_data) }
  subject(:builder_with_decorators) { Grom::Builder.new(reader_with_data, Parliament::Grom::Decorator) }



  describe '#intialize' do
    it 'stores reader into @reader' do
      expect(builder_without_decorators.instance_variable_get(:@reader)).to eq(reader_with_data)
    end

    it 'defaults @decorators to nil' do
      expect(builder_without_decorators.instance_variable_get(:@decorators)).to be_nil
    end

    it 'creates objects' do
      expect(builder_without_decorators.objects.size).to eq(6)
    end

    context 'with decorators' do
      it 'stores decorators into @decorators' do
        expect(builder_with_decorators.instance_variable_get(:@decorators)).to eq(Parliament::Grom::Decorator)
      end

      it 'creates decorated objects' do
        expect(builder_with_decorators.objects.first).to be_kind_of(Parliament::Grom::Decorator::Person)
      end
    end

    context 'without decorators' do
      it 'creates un-decorated objects' do
        expect(builder_without_decorators.objects.first).not_to be_kind_of(Parliament::Grom::Decorator::Person)
      end
    end
  end

  describe '#build_objects_by_subject' do
    context 'data passed' do
      subject {Grom::Builder.new(reader)}

      it 'creates all of the objects for each subject' do
        reader.instance_variable_set(:@statements_by_subject, statements_by_subject)
        reader.instance_variable_set(:@subjects_by_type, subjects_by_type)
        writer = subject.build_objects_by_subject
        expect(writer.instance_variable_get(:@objects).size).to eq(6)
      end

      context 'with decorators' do
        it 'passes decorators to Grom::Node.new' do
          statements_by_subject.keys.each do |subject|
            expect(Grom::Node).to receive(:new).with(statements_by_subject[subject], Parliament::Grom::Decorator)
          end

          builder_with_decorators
        end
      end
    end

    context 'multiple objects' do
      let(:multiple_object_reader) { Grom::Reader.new(StringIO.new(File.read('spec/fixtures/constituency.nt'))) }
      subject {Grom::Builder.new(multiple_object_reader)}

      it 'create array of objects' do
        writer = subject.build_objects_by_subject
        objects = writer.instance_variable_get(:@objects)

        expect(objects.last.constituencyAreaExtent).to be_a(Array)
        expect(objects.last.constituencyAreaExtent.size).to eq(2)
      end
    end
  end

  describe '#link_objects' do
    let(:data) { StringIO.new(File.read('spec/fixtures/people_members_current.nt')) }
    let(:reader) { Grom::Reader.new(data) }
    subject { Grom::Builder.new(reader) }

    context 'data passed' do
      it 'links together related objects' do
        writer  = subject.build_objects_by_subject.link_objects
        objects = writer.instance_variable_get(:@objects)

        objects.first.personHasSitting.first.sittingHasHouse.first.houseHasSitting.each do |sitting|
          expect(sitting.type).to eq('http://id.ukpds.org/schema/Sitting')
        end
      end
    end

    context 'empty @objects_by_subject data' do
      it 'will not call method if @objects_by_subject is nil' do
        writer = subject.build_objects_by_subject
        writer.instance_variable_set(:@objects_by_subject, {})

        expect(writer.link_objects).not_to receive(:instance_variable_set)
      end
    end

    context 'incorrect predicate name used' do
      let(:error_data) { StringIO.new(File.read('spec/fixtures/naming_error.nt')) }
      let(:error_reader) { Grom::Reader.new(error_data) }
      subject { Grom::Builder.new(error_reader) }

      it 'raises a Parliament::NamingError' do
        expect { subject.build_objects_by_subject.link_objects }.to raise_error(Grom::NamingError)
      end
    end

  end
end
