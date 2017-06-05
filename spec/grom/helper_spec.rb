require_relative '../spec_helper'

describe Grom::Helper do
  it 'is a module' do
    expect(Grom::Helper).to be_a(Module)
  end

  context '#pluralize_instance_variable_symbol' do
    it 'manipulates a string and returns a symbol we can use as a method name' do
      expect(Grom::Helper.pluralize_instance_variable_symbol('sittingHasPerson')).to eq(:@sitting_has_people)
      expect(Grom::Helper.pluralize_instance_variable_symbol('House')).to eq(:@houses)
    end
  end

  context '#lazy_array_insert' do
    context 'array is not nil' do
      it 'checks if array exists, and if not then creates it, then appends value to array' do
        expect(Grom::Helper.lazy_array_insert({ :numbers => [1, 2, 3] }, :numbers, 4)).to eq([1, 2, 3, 4])
      end
    end
    context 'array is nil' do
      it 'checks if array exists, and if not then creates it, then appends value to array' do
        expect(Grom::Helper.lazy_array_insert({}, :numbers, 4)).to eq([4])
      end
    end
  end

  describe 'self#get_id' do
    it 'strips a type correctly' do
      expect(Grom::Helper.get_id(RDF.type)).to eq('type')
    end

    it 'strips a label correctly' do
      expect(Grom::Helper.get_id(RDF::RDFS.label)).to eq('label')
    end

    it 'strips a uri correctly' do
      expect(Grom::Helper.get_id('http://google.com/12345-567-a910')).to eq('12345-567-a910')
    end

    it 'handles a nil value' do
      expect(Grom::Helper.get_id(nil)).to eq(nil)
    end

    it 'handles an empty string' do
      expect(Grom::Helper.get_id('')).to eq(nil)
    end

    it 'handles a non-string object' do
      expect(Grom::Helper.get_id(%w(a b c))).to eq(nil)
    end
  end
end
