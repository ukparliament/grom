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
  let(:people_with) { DummyPerson.eager_all('apple') }
  let(:person_with) { DummyPerson.eager_find('9') }
  let(:person_with_current_party) { DummyPerson.eager_find('9', 'parties', 'current') }

  describe '#find' do
    it 'should return an instance of the class that it is called from - DummyPerson' do
      expect(dummy_person).to be_a DummyPerson
    end
  end

  describe '#all' do
    it 'should return an array of two objects of type DummyPerson' do
      expect(dummy_people.count).to eq 2
      expect(dummy_people[0]).to be_a DummyPerson
      expect(dummy_people[1]).to be_a DummyPerson
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

  describe '#eager_all' do
    it 'should return an array of two objects of type DummyPerson' do
      expect(people_with.count).to eq 2
    end

    it 'should create a property .party for each person and the name should be Liberal Democrat' do
      expect(people_with[0].dummy_party.name).to eq 'Liberal Democrat'
      expect(people_with[1].dummy_party.name).to eq 'Liberal Democrat'
    end
  end

  describe '#eager_find' do
    it 'should return a single person with her core properties' do
      expect(person_with.forename).to eq 'Daenerys'
    end

    it 'should assign the correct sub-properties to the person' do
      expect(person_with.dummy_parties.first.name).to eq 'Liberal Democrat'
    end

    it 'should return the party_memberships and each one should have one party and one cat' do
      expect(person_with.dummy_party_memberships.first.end_date).to eq '1954-01-12'
      expect(person_with.dummy_party_memberships.first.dummy_party.name).to eq 'Liberal Democrat'
      expect(person_with.dummy_party_memberships.first.dummy_cat.name).to eq 'Felix'
      expect(person_with.dummy_party_memberships.last.dummy_cat.name).to eq 'Bob'
    end

    it 'should be able to return a single person with a current party' do
      expect(person_with_current_party.forename).to eq 'Daenerys'
    end

    it 'should assign the correct sub-properties to the person' do
      expect(person_with_current_party.dummy_parties.first.name).to eq 'Liberal Democrat'
    end
  end

  describe '#object_array_maker' do
    it 'should return an array of dummy_people when given graph data with all the right properties set' do
      dummies = DummyPerson.object_array_maker(PEOPLE_TTL)
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
      dummy = DummyPerson.object_single_maker(PERSON_ONE_TTL)
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

  describe '#property_getter_setter' do
    it 'should create getter and setter methods for an object given an association' do
      DummyPerson.property_getter_setter('cats')
      expect(dummy_person).to respond_to(:cats)
      expect(dummy_person).to respond_to(:cats=)
    end
  end
  
  describe '#map_hashes_to_objects' do
    it 'should return an array of objects, given hashes for the associated objects and through objects' do
      DummyPerson.property_getter_setter("dummy_party_memberships")
      arr = DummyPerson.map_hashes_to_objects(BLANK_PARTY_MEMBERSHIPS_HASH, "dummy_party_memberships")
      expect(arr.first.forename).to eq 'Daenerys'
      expect(arr.first.surname).to eq 'Targaryen'
      expect(arr.first.dummy_party_memberships.count).to eq 2
    end
  end
end