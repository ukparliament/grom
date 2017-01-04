class DummySquirrel < Grom::Base

  def self.context
            {
                "xsd": "http://www.w3.org/2001/XMLSchema#",
                "DummySquirrel": "http://id.example.com/schema/DummySquirrel",
                "name": "http://id.example.com/schema/name",
                "date_of_birth":
                    {
                        "@id": "http://id.example.com/schema/date_of_birth",
                        "@type": "xsd:date"
                    }
            }
  end

  def self.id_prefix
    "http://id.example.com/"
  end

  def self.type
    "DummySquirrel"
  end

  def self.property_translator
    {
        id: 'id',
        name: 'name',
        dateOfBirth: 'date_of_birth'
    }
  end
end