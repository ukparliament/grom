require 'spec_helper'

describe Grom::Base do

  let(:dummy_person) { DummyPerson.find('1') }
  let(:dummy_people) { DummyPerson.all }
  let(:name_pattern) { RDF::Query::Pattern.new(:subject, RDF::URI.new("#{DATA_URI_PREFIX}/schema/name"), :object) }
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

    it 'should work with names that have got an apostrophe' do
      dogs = DummyDog.all
      buddy = dogs.select { |d| d.id == '1863' }.first
      fido = dogs.select { |d| d.id == '1866' }.first
      expect(buddy.name).to eq "B'uddy"
      expect(fido.name).to eq "F'ido"
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

  describe '#has_many_through' do
    it 'should create a has_many_through association for a given class and be able to call the through_class on the association' do
      dummy_party = DummyParty.find('81')
      members = dummy_party.dummy_members
      party_membership = members.first.dummy_party_memberships.select { |h| h[:id] == '42' }.first
      expect(members.first.forename).to eq 'Daenerys'
      expect(party_membership[:partyMembershipStartDate]).to eq '1944-01-12'
      expect(party_membership[:partyMembershipEndDate]).to eq '1954-01-12'
      expect(party_membership[:associated_object_id]).to eq '1'
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

    it 'should return a graph even when there are single quotes in the ttl data' do
      graph = DummyDog.find('1863').graph
      expect(graph.query(name_pattern).first_object.to_s).to eq "B'uddy"
    end
  end

  describe '#serialize_associated_objects' do
    it 'should return a hash with the object and its associated objects in an array' do
      person_hash = dummy_person.serialize_associated_objects(:dummy_contact_points)
      contact_point = person_hash[:dummy_contact_points][0]
      expect(person_hash[:dummy_person]).to eq dummy_person
      expect(contact_point.id).to eq '123'
      expect(contact_point.postal_code).to eq 'SW1A 0AA'
      expect(contact_point.street_address).to eq 'House of Commons'
      expect(contact_point.address_locality).to eq 'London'
      expect(contact_point.telephone).to eq '020 7555 5555'
      expect(contact_point.email).to eq 'daenerys@khaleesi.com'
    end

    xit 'should return a hash with the object, its associated objects in an array, and the through objects in an array' do
      person_hash = dummy_person.serialize_associated_objects(:dummy_parties)
      party_one = person_hash[:dummy_parties].select{ |o| o.id == '23'}.first
      party_two = person_hash[:dummy_parties].select{ |o| o.id == '26'}.first
      party_one_membership = party_one.dummy_party_memberships[0]
      party_two_membership = party_two.dummy_party_memberships[0]
      expect(person_hash[:dummy_person]).to eq dummy_person
      expect(party_one.name).to eq 'Targaryens'
      expect(party_two.name).to eq 'Dothrakis'
      expect(party_one_membership.id).to eq '25'
      expect(party_one_membership.start_date).to eq '1953-01-12'
      expect(party_one_membership.end_date).to eq '1954-01-12'
      expect(party_two_membership.id).to eq '27'
      expect(party_two_membership.start_date).to eq '1954-01-12'
      expect(party_two_membership.end_date).to eq '1955-03-11'
    end

    it 'should return a hash with the object and two associations' do
      person_hash = dummy_person.serialize_associated_objects(:dummy_contact_points, :dummy_cat)
      contact_points = person_hash[:dummy_contact_points][0]
      cat = person_hash[:dummy_cat]
      expect(person_hash[:dummy_person]).to eq dummy_person
      expect(contact_points.id).to eq '123'
      expect(contact_points.postal_code).to eq 'SW1A 0AA'
      expect(contact_points.street_address).to eq 'House of Commons'
      expect(contact_points.address_locality).to eq 'London'
      expect(contact_points.telephone).to eq '020 7555 5555'
      expect(contact_points.email).to eq 'daenerys@khaleesi.com'
      expect(cat.id).to eq '123'
      expect(cat.name).to eq 'Bob'
    end

    it 'should return a hash with the correct objects, given the flag current' do
      person_hash = dummy_person.serialize_associated_objects(dummy_contact_points: 'current')
      contact_point = person_hash[:dummy_contact_points][0]
      expect(person_hash[:dummy_person]).to eq dummy_person
      expect(contact_point.id).to eq '123'
      expect(contact_point.postal_code).to eq 'SW1A 0AA'
      expect(contact_point.street_address).to eq 'House of Commons'
      expect(contact_point.address_locality).to eq 'London'
      expect(contact_point.telephone).to eq '020 7555 5555'
      expect(contact_point.email).to eq 'daenerys@khaleesi.com'
    end

    it 'should return a hash with the correct objects, given a mix of arguments' do
      person_hash = dummy_person.serialize_associated_objects({dummy_contact_points: 'current' }, :dummy_cat)
      contact_point = person_hash[:dummy_contact_points][0]
      cat = person_hash[:dummy_cat]
      expect(person_hash[:dummy_person]).to eq dummy_person
      expect(contact_point.id).to eq '123'
      expect(contact_point.postal_code).to eq 'SW1A 0AA'
      expect(contact_point.street_address).to eq 'House of Commons'
      expect(contact_point.address_locality).to eq 'London'
      expect(contact_point.telephone).to eq '020 7555 5555'
      expect(contact_point.email).to eq 'daenerys@khaleesi.com'
      expect(cat.id).to eq '123'
      expect(cat.name).to eq 'Bob'
    end
  end

  xdescribe '#apples' do
    it 'bla bla' do
      dummy_party = DummyParty.find('81')
      members = dummy_party.dummy_members
      expect(members.first.forename).to eq 'Daenerys'
      expect(members.first.dummy_party_memberships[0][:partyMembershipStartDate]).to eq '1944-01-12'
    end
  end
end