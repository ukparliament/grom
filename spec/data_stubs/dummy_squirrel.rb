class DummySquirrel < Grom::Base

  def self.context
    {
        "@context":
            {
                "xsd": "http://www.w3.org/2001/XMLSchema#",
                "name": "http://id.example.com/schema/name",
                "age":
                    {
                        "@id": "http://id.example.com/schema/age",
                        "@type": "xsd:integer"
                    }
            }
    }
  end

  def self.property_translator
    {
        id: 'id',
        name: 'name',
        dateOfBirth: 'date_of_birth'
    }
  end
end