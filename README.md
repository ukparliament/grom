# Graph Object Mapper (Grom)
Grom is a custom ORM that takes graph data and deserializes it into objects. It uses the [RDF.rb](https://github.com/ruby-rdf/rdf) library. It was created in the context
of UK Parliament's new website. 

## Installation
```apple js
gem install grom
```
Add this line to your application's Gemfile:

```ruby
gem 'grom'
```

Then execute:
```bash
$ bundle
```

## Usage

#### Set up
You will need to set three constants in order for the gem to work. 

```
API_ENDPOINT = 'http://example.com'
API_ENDPOINT_HOST = 'example.com'
DATA_URI_PREFIX = 'http://id.example.com'
```

The API Endpoint will be the endpoint where you are making the calls to get graph data. <br>
The Data URI prefix is the prefix that you use to define the entities in your triple store.


#### Models
Models inherit from `Grom::Base` and need a `self.property_translator` hash defined.   The keys are predicates (without the prefix) and the values are the translated object properties.

An example of a Person class.

```
class Person < Grom::Base

  def self.property_translator
    {
        id: 'id',
        forename: 'forename',
        surname: 'surname',
        middleName: 'middle_name',
        dateOfBirth: 'date_of_birth'
    }
  end
end
```

#### Retrieving Objects

##### #all
To return a collection of objects use the class method `all`.
```apple js
people = Person.all #=> returns an array of People objects
```

This method can take unlimited parameters.  Including a parameter appends it to the endpoint url creating a new url.  For example,

```apple js
people = Person.all('current') #=> returns an array of current People
```
This generates the endpoint url `http://#{API_ENDPOINT}/people/current.ttl` and returns a list of current people from there.

##### #find
To return a single object use the class method `find` with an id.
```apple js
person = Person.find('1') #=> returns a Person object
```

#### Associations

##### #has_many
For a simple `has_many` association, declare the association at the top of the model. For example, if `Person` has many `contact_points`, create a `ContactPoint` class and declare the association at the top of the `Person` class.

The name of the association must match the name of the class but it needs to be underscored and pluralized just like in ActiveRecord.

```
class Person < Grom::Base
  has_many :contact_points
```

It is then possible to retrieve the contact_points for a person in the following way:

```apple js
person = Person.find('1')
person.contact_points #=> returns an array of contact_points related to person
```

##### #has_many_through
For a `has_many_through` association, declare the association at the top of the model. For example, if `Person` has many `parties` through `party_memberships`, create a `Party` class and a `PartyMembership` class, then declare the association at the top of the `Person` class.

```
class Person < Grom::Base
  has_many_through :parties, via: :party_memberships
```

It is then possible to retrieve the parties for a person in the following way:

```apple js
person = Person.find('1')
person.parties #=> returns an array of parties with the party_memberships stored as a hash
```


## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
