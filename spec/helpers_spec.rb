require 'spec_helper'

describe Grom::Helpers do

  let(:extended_class) { Class.new { extend Grom::Helpers } }

  describe '#url_builder' do
    it 'should return an endpoint when given a class and an associated class' do
      dummy = DummyPerson.find('1')
      url = extended_class.url_builder(dummy, "Party", {})
      expect(url).to eq "#{API_ENDPOINT}/dummy_people/1/parties.ttl"
    end

    it 'should return an endpoint when given a class, an associated class and an options hash with optional set' do
      dummy = DummyPerson.find('1')
      url = extended_class.url_builder(dummy, "Party", { optional: "current" })
      expect(url).to eq "#{API_ENDPOINT}/dummy_people/1/parties/current.ttl"
    end

    it 'should return an endpoint when given a class, an associated class and an options hash with single set to true' do
      dummy = DummyPerson.find('1')
      url = extended_class.url_builder(dummy, "Party", { single: true })
      expect(url).to eq "#{API_ENDPOINT}/dummy_people/1/party.ttl"
    end
  end

  describe '#base_url_builder' do
    it 'should return a url with the api_endpoint and the pluralized, underscored and downcased name of the class when you do not prvodie an id' do
      url = extended_class.base_url_builder("ContactPerson")
      expect(url).to eq "#{API_ENDPOINT}/contact_people"
    end

    it 'should return a url with the api_endpoint and the pluralized, underscored and downcased name of the class and an id when provided' do
      url = extended_class.base_url_builder("ContactPerson", "1")
      expect(url).to eq "#{API_ENDPOINT}/contact_people/1"
    end
  end

  describe '#create_class_name' do
    it 'should camelize, capitalize and singularize any plural underscore properties' do
      expect(extended_class.create_class_name('dummy_party_memberships')).to eq 'DummyPartyMembership'
    end
  end

  describe '#create_property_name' do
    it 'should underscore and downcase any singular class name' do
      expect(extended_class.create_property_name('DummyPerson')).to eq 'dummy_person'
    end
  end

  describe '#create_plural_property_name' do
    it 'should underscore, downcase and pluralize any singular class name' do
      expect(extended_class.create_plural_property_name('DummyPerson')).to eq 'dummy_people'
    end
  end

end