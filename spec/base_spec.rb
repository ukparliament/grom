require 'spec_helper'

describe Grom::Base do

  let(:dummy_person) { DummyPerson.find('1') }
  let(:dummy_people) { DummyPerson.all }
  let(:surname_pattern) { RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/surname"), :object) }
  let(:forename_pattern) { RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/forename"), :object) }
  let(:middle_name_pattern) { RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/middleName"), :object) }
  let(:date_of_birth_pattern) { RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/dateOfBirth"), :object) }
  let(:gender_pattern) { RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/gender"), :object) }

  describe '#find' do
    it 'should return an instance of the class that it is called from - DummyPerson' do
      expect(dummy_person).to be_a DummyPerson
    end

    it 'should return an object that has a graph method with the correct statements' do
      expect(dummy_person).to respond_to(:graph)
      graph = dummy_person.graph
      expect(graph.query(forename_pattern).first_object.to_s).to eq 'Daenerys'
      expect(graph.query(surname_pattern).first_object.to_s).to eq 'Targaryen'
      expect(graph.query(middle_name_pattern).first_object.to_s).to eq 'Khaleesi'
      expect(graph.query(date_of_birth_pattern).first_object.to_s).to eq '1947-06-29'
      expect(graph.query(gender_pattern).first_object.to_s).to eq 'http://id.example.com/schema/Female'
    end
  end

  describe '#all' do
    it 'should return an array of two objects of type DummyPerson' do
      expect(dummy_people.count).to eq 2
      expect(dummy_people[0]).to be_a DummyPerson
      expect(dummy_people[1]).to be_a DummyPerson
    end

    it 'should return an array of two objects and each one should have a graph with the correct statements' do
      daenerys_graph = dummy_people.select{ |o| o.id == '1' }.first.graph
      expect(daenerys_graph.query(forename_pattern).first_object.to_s).to eq 'Daenerys'
      expect(daenerys_graph.query(surname_pattern).first_object.to_s).to eq 'Targaryen'
      expect(daenerys_graph.query(middle_name_pattern).first_object.to_s).to eq 'Khaleesi'
      expect(daenerys_graph.query(date_of_birth_pattern).first_object.to_s).to eq '1947-06-29'
      expect(daenerys_graph.query(gender_pattern).first_object.to_s).to eq 'http://id.example.com/schema/Female'
      arya_graph = dummy_people.select{ |o| o.id == '2' }.first.graph
      expect(arya_graph.query(forename_pattern).first_object.to_s).to eq 'Arya'
      expect(arya_graph.query(surname_pattern).first_object.to_s).to eq 'Stark'
      expect(arya_graph.query(middle_name_pattern).first_object.to_s).to eq 'The Blind Girl'
      expect(arya_graph.query(date_of_birth_pattern).first_object.to_s).to eq '1954-01-12'
      expect(arya_graph.query(gender_pattern).first_object.to_s).to eq 'http://id.example.com/schema/Female'
    end

    it 'given an optional argument, should return an array of two objects of type DummyPerson' do
      dummy_people_current = DummyPerson.all('current')
      expect(dummy_people_current.count).to eq 2
      expect(dummy_people_current[0]).to be_a DummyPerson
      expect(dummy_people_current[1]).to be_a DummyPerson
    end

    it 'given more than one optional argument, should still return an array of objects according to what the endpoint returns' do
      dummy_members_current_banana = DummyPerson.all('members', 'current', 'banana')
      expect(dummy_members_current_banana.count).to eq 2
      expect(dummy_members_current_banana[0]).to be_a DummyPerson
      expect(dummy_members_current_banana[1]).to be_a DummyPerson
    end
  end

  describe '#object_array_maker' do
    it 'should return an array of dummy_people when given graph data with all the right properties set' do
      dummies = DummyPerson.object_array_maker(PEOPLE_GRAPH)
      daenerys_dummy = dummies.select{ |o| o.id == '1' }.first
      expect(daenerys_dummy.forename).to eq 'Daenerys'
      expect(daenerys_dummy.surname).to eq 'Targaryen'
      expect(daenerys_dummy.middle_name).to eq 'Khaleesi'
      expect(daenerys_dummy.date_of_birth).to eq '1947-06-29'
      arya_dummy = dummies.select{ |o| o.id == '2' }.first
      expect(arya_dummy.forename).to eq 'Arya'
      expect(arya_dummy.surname).to eq 'Stark'
      expect(arya_dummy.middle_name).to eq 'The Blind Girl'
      expect(arya_dummy.date_of_birth).to eq '1954-01-12'
    end
  end

  describe '#object_single_maker' do
    it 'should return a single object given graph data with all the right properties' do
      dummy = DummyPerson.object_single_maker(PERSON_ONE_GRAPH)
      expect(dummy.forename).to eq 'Daenerys'
      expect(dummy.id).to eq '1'
      expect(dummy.surname).to eq 'Targaryen'
      expect(dummy.middle_name).to eq 'Khaleesi'
      expect(dummy.date_of_birth).to eq '1947-06-29'
      expect(dummy.gender).to eq 'female'
    end
  end

  describe '#has_many' do
    it 'should create a has_many association for a given class' do
        expect(dummy_person).to respond_to(:dummy_contact_points)
        expect(dummy_person.dummy_contact_points[0].street_address).to eq 'House of Commons'
    end
  end

  describe '#has_one' do
    it 'should create a has_one association for a given class' do
      expect(dummy_person).to respond_to(:dummy_cat)
      expect(dummy_person.dummy_cat.name).to eq 'Bob'
    end
  end

  xdescribe '#has_many_through' do
    it 'should create a has_many_through association for a given class and be able to call the through_class on the association' do
      expect(dummy_person.dummy_parties[0].name).to eq 'Targaryens'
      expect(dummy_person.dummy_parties[0].dummy_party_memberships[0].start_date).to eq '1953-01-12'
      expect(dummy_person.dummy_parties[0].dummy_party_memberships[0].end_date).to eq '1954-01-12'
    end
  end

  describe '#through_getter_setter' do
    it 'should create getter and setter methods for an object given an association' do
      DummyPerson.through_getter_setter('cats')
      expect(dummy_person).to respond_to(:cats)
      expect(dummy_person).to respond_to(:cats=)
    end
  end

  describe '#graph' do
    it 'should return the graph for the object it is called on' do
      graph = dummy_person.graph
      expect(graph.query(surname_pattern).first_object.to_s).to eq 'Targaryen'
      expect(graph.query(forename_pattern).first_object.to_s).to eq 'Daenerys'
      expect(graph.query(middle_name_pattern).first_object.to_s).to eq 'Khaleesi'
      expect(graph.query(date_of_birth_pattern).first_object.to_s).to eq '1947-06-29'
      expect(graph.query(gender_pattern).first_object.to_s).to eq 'http://id.example.com/schema/Female'
    end
  end

end