class DummyCat < Grom::Base
  def self.property_translator
    {
        id: 'id',
        name: 'name',
    }
  end
end