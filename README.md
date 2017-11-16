# [![Graph Object Mapper (GROM)][grom-logo]][grom]
[GROM][grom] is a gem created by the [Parliamentary Digital Service][pds] to take [ntriple][ntriple] files representing graph data and deserialise them into ruby objects.

[![Build Status][shield-travis]][info-travis] [![Test Coverage][shield-coveralls]][info-coveralls] [![License][shield-license]][info-license]

> **NOTE:** This gem is in active development and is likely to change at short notice. It is not recommended that you use this in any production environment.

### Contents
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Getting Started with Development](#getting-started-with-development)
  - [Running the tests](#running-the-tests)
- [Contributing](#contributing)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Requirements
[GROM][grom] requires the following:
* [Ruby][ruby] - [click here][ruby-version] for the exact version
* [Bundler][bundler]


## Installation
```bash
gem 'grom'
```


## Usage
This gem's main function is taking an [ntriple][ntriple] data stream and deserialising it into linked `Grom::Node` objects.

```ruby
file = File.read('people_members_current.nt')
data_stream = StringIO.new(file)

objects = Grom::Reader.new(data_stream).objects #=> [<#Grom::Node ...>, <#Grom::Node ...>, ...]
```


## Getting Started with Development
To clone the repository and set up the dependencies, run the following:
```bash
git clone https://github.com/ukparliament/grom.git
cd grom
bundle install
```

### Running the tests
We use [RSpec][rspec] as our testing framework and tests can be run using:
```bash
bundle exec rake
```


## Contributing
If you wish to submit a bug fix or feature, you can create a pull request and it will be merged pending a code review.

1. Fork the repository
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Ensure your changes are tested using [Rspec][rspec]
1. Create a new Pull Request


## License
[grom][grom] is licensed under the [Open Parliament Licence][info-license].

Logo design by [Anna Vámos][anna-vamos].

[ruby]:         https://www.ruby-lang.org/en/
[bundler]:      http://bundler.io
[rspec]:        http://rspec.info 
[grom-logo]:    https://cdn.rawgit.com/ukparliament/grom/85df4d355313358930cea8aa2fbfc53dd3e4f8d3/docs/logo.svg
[grom]:         https://github.com/ukparliament/grom
[pds]:          https://www.parliament.uk/mps-lords-and-offices/offices/bicameral/parliamentary-digital-service/
[ruby-version]: https://github.com/ukparliament/grom/blob/master/.ruby-version
[anna-vamos]:   https://www.linkedin.com/in/annavamos
[ntriple]:      https://en.wikipedia.org/wiki/N-Triples

[info-travis]:   https://travis-ci.org/ukparliament/grom
[shield-travis]: https://img.shields.io/travis/ukparliament/grom.svg

[info-coveralls]:   https://coveralls.io/github/ukparliament/grom
[shield-coveralls]: https://img.shields.io/coveralls/ukparliament/grom.svg

[info-license]:   https://www.parliament.uk/site-information/copyright-parliament/open-parliament-licence/
[shield-license]: https://img.shields.io/badge/license-Open%20Parliament%20Licence-blue.svg
