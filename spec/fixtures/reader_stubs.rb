CONNECTIONS_BY_SUBJECT=
    {"http://id.ukpds.org/HouseOfCommons"=>["http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7"],
     "http://id.ukpds.org/4ef6c7b7-a5c8-4dde-a5a5-29c9f80d8a27"=>["http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7"],
     "http://id.ukpds.org/80234c90-f86a-4942-b6ae-d1e57a0b378d"=>["http://id.ukpds.org/b40f3248-3f53-4af5-8349-024db28d2636"],
     "http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7"=>
         ["http://id.ukpds.org/4ef6c7b7-a5c8-4dde-a5a5-29c9f80d8a27", "http://id.ukpds.org/HouseOfCommons", "http://id.ukpds.org/cea89432-e046-4013-a9ba-e93d0468d186"],
     "http://id.ukpds.org/b40f3248-3f53-4af5-8349-024db28d2636"=>
         ["http://id.ukpds.org/80234c90-f86a-4942-b6ae-d1e57a0b378d", "http://id.ukpds.org/cea89432-e046-4013-a9ba-e93d0468d186"]}

STATEMENTS_BY_SUBJECT=
    {"http://id.ukpds.org/cea89432-e046-4013-a9ba-e93d0468d186"=>
         [RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/cea89432-e046-4013-a9ba-e93d0468d186'), RDF.type, RDF::URI.new('http://id.ukpds.org/schema/Person')),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/cea89432-e046-4013-a9ba-e93d0468d186'), RDF::URI.new('http://id.ukpds.org/schema/forename'), 'Person 1 - forename'),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/cea89432-e046-4013-a9ba-e93d0468d186'), RDF::URI.new('http://id.ukpds.org/schema/surname'),'Person 1 - surname')],
     "http://id.ukpds.org/HouseOfCommons"=>
         [RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/HouseOfCommons'), RDF.type, RDF::URI.new('http://id.ukpds.org/schema/House')),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/HouseOfCommons'), RDF::URI.new('http://id.ukpds.org/schema/connect'), RDF::URI.new('http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7'))],
     "http://id.ukpds.org/4ef6c7b7-a5c8-4dde-a5a5-29c9f80d8a27"=>
         [RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/4ef6c7b7-a5c8-4dde-a5a5-29c9f80d8a27'), RDF.type, RDF::URI.new('http://id.ukpds.org/schema/Constituency')),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/4ef6c7b7-a5c8-4dde-a5a5-29c9f80d8a27'), RDF::URI.new('http://id.ukpds.org/schema/constituencyName'), 'Constituency 1 - name'),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/4ef6c7b7-a5c8-4dde-a5a5-29c9f80d8a27'), RDF::URI.new('http://id.ukpds.org/schema/connect'), RDF::URI.new('http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7'))],
     "http://id.ukpds.org/80234c90-f86a-4942-b6ae-d1e57a0b378d"=>
         [RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/80234c90-f86a-4942-b6ae-d1e57a0b378d'), RDF.type, RDF::URI.new('http://id.ukpds.org/schema/Party')),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/80234c90-f86a-4942-b6ae-d1e57a0b378d'), RDF::URI.new('http://id.ukpds.org/schema/partyName'), 'Party 1 - name'),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/80234c90-f86a-4942-b6ae-d1e57a0b378d'), RDF::URI.new('http://id.ukpds.org/schema/connect'), RDF::URI.new('http://id.ukpds.org/b40f3248-3f53-4af5-8349-024db28d2636'))],
     "http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7"=>
         [RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7'), RDF.type, RDF::URI.new('http://id.ukpds.org/schema/Sitting')),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7'), RDF::URI.new('http://id.ukpds.org/schema/sittingStartDate'), '2016-05-03'),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7'), RDF::URI.new('http://id.ukpds.org/schema/connect'), RDF::URI.new('http://id.ukpds.org/4ef6c7b7-a5c8-4dde-a5a5-29c9f80d8a27')),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7'), RDF::URI.new('http://id.ukpds.org/schema/connect'), RDF::URI.new('http://id.ukpds.org/HouseOfCommons')),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7'), RDF::URI.new('http://id.ukpds.org/schema/connect'), RDF::URI.new('http://id.ukpds.org/cea89432-e046-4013-a9ba-e93d0468d186'))],
     "http://id.ukpds.org/b40f3248-3f53-4af5-8349-024db28d2636"=>
         [RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/b40f3248-3f53-4af5-8349-024db28d2636'), RDF.type, RDF::URI.new('http://id.ukpds.org/schema/PartyMembership')),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/b40f3248-3f53-4af5-8349-024db28d2636'), RDF::URI.new('http://id.ukpds.org/schema/partyMembershipStartDate'), '2016-05-03'),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/b40f3248-3f53-4af5-8349-024db28d2636'), RDF::URI.new('http://id.ukpds.org/schema/connect'), RDF::URI.new('http://id.ukpds.org/80234c90-f86a-4942-b6ae-d1e57a0b378d')),
          RDF::Statement.new(RDF::URI.new('http://id.ukpds.org/b40f3248-3f53-4af5-8349-024db28d2636'), RDF::URI.new('http://id.ukpds.org/schema/connect'), RDF::URI.new('http://id.ukpds.org/cea89432-e046-4013-a9ba-e93d0468d186'))]}

SUBJECTS_BY_TYPE=
    {"Person"=>["http://id.ukpds.org/cea89432-e046-4013-a9ba-e93d0468d186"],
     "House"=>["http://id.ukpds.org/HouseOfCommons"],
     "Constituency"=>["http://id.ukpds.org/4ef6c7b7-a5c8-4dde-a5a5-29c9f80d8a27"],
     "Party"=>["http://id.ukpds.org/80234c90-f86a-4942-b6ae-d1e57a0b378d"],
     "Sitting"=>["http://id.ukpds.org/6569ce56-020e-4c43-a36e-ca5bf3e576b7"],
     "PartyMembership"=>["http://id.ukpds.org/b40f3248-3f53-4af5-8349-024db28d2636"]}