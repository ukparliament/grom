# Graph Object Mapper (Grom)
Grom is a custom ORM that takes graph data and deserializes it into objects. It uses the ruby-rdf library. We created it in the context
of UK Parliament new website. 

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'grom', git: "https://github.com/ukpds/grom"
```

And then execute:
```bash
$ bundle
```

## Usage

#### Set up
You will need to set three constants in order for the package to work. 

```
API_ENDPOINT = 'http://example.com'
API_ENDPOINT_HOST = 'example.com'
DATA_URI_PREFIX = 'http://id.example.com'
```

Your Api Endpoint will be where you are making the calls to get your graph data. <br>
Your Data URI prefix is just the prefix that you use to define the entities in your triple store.


#### Models
In order for the deserialization to work, your models will need to inherit from `Grom::Base` and you will need to define a `self.property_translator` hash where the key should be the predicate (without the prefix) and the value should be whatever you want to call the property of the object.

Here is an example of a Person class.

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

#### Associations

##### #has_many
For a simple `has_many` association, you need to declare the association at the top of the model. For example, if `Person` has many `contact_points`, you need to have a `ContactPoint` class and you would declare the association at the top of the `Person` class.

The name of the association must match the name of the class but it needs to be underscored and pluralized just like in ActiveRecord.

```
class Person < Grom::Base
  has_many :contact_points
```


##### #has_many_through
For a `has_many_through` association, you need to declare the association at the top of the model. For example, if `Person` has many `parties` through `party_memberships`, you need to have a `Party` class and a `PartyMembership` and you would declare the association at the top of the `Person` class.

```
class Person < Grom::Base
  has_many_through :parties, via: :party_memberships
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
