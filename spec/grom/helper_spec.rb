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
        expect(Grom::Helper.lazy_array_insert({5 => [1, 2, 3]}, 5, 4)).to eq([1, 2, 3, 4])
      end
    end
    context 'array is nil' do
      it 'checks if array exists, and if not then creates it, then appends value to array' do
        expect(Grom::Helper.lazy_array_insert({}, 5, 4)).to eq([4])
      end
    end
  end
end
