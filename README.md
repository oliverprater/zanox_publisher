# ZanoxPublisher

This is a ruby wrapper for the [ZANOX Publisher API](https://developer.zanox.com/web/guest/publisher-api-2011), released on March 1, 2011.

## Installation

The simplest way to install ZanoxPublisher is with [Bundler](http://gembundler.com/).

Add this line to your application's `Gemfile`:

```ruby
gem 'zanox_publisher'
```

And then execute:

    $ bundle

Or install it yourself:

    $ gem install zanox_publisher

## Configuration

The Zanox Publisher API requires a connect ID and a secret key to make requests directly related with the account.
General information can often be retrieved with just the connect ID.

The required information for each request can be found in the [documentation][documentation].

The connect ID and secret key can be set with the authenticate method:

```ruby
ZanoxPublisher.authenticate('Connect ID', 'Secret key')
```

Or directly on ZanoxPublisher.

```ruby
ZanoxPublisher.connect_id = 'Connect ID'
ZanoxPublisher.secret_key = 'Secret key'
```

## Usage

The gem is designed for integratation with Ruby on Rails in mind.
The method names try to follow the common methods found on an ActiveRecord object.

### Usage with Rails

Install ZanoxPublisher by adding it to your projects `Gemfile`.

```ruby
gem 'zanox_publisher'
```

And then execute:

    $ bundle

Finally, create an initializer file `config/initializers/zanox_publisher.rb` to hold the configuration.

```ruby
ZanoxPublisher.authenticate('Connect ID', 'Secret key')
```

To make an API call in your application simply use the gems corresponding ruby object.

### Usage outside of Rails

To use ZanoxPublisher in plain ruby require the gem and set the configuration before running your code.

```ruby
require 'zanox_publisher'

ZanoxPublisher.authenticate('Connect ID', 'Secret key')

# Your code here
```

### Basic examples

ZanoxPublisher is designed to be a full ruby object representation for each of the Zanox API endpoints.
The matching of ruby objects to Zanox API method name's is given in the List of Objects.

The examples below expect that ZanoxPublisher is correctly configured and show only some basic usage examples.
Check the [documentation][documentation] for the complete reference.

**Search for a program that sells hats**

```ruby
programs_that_sell_hats = ZanoxPublisher::Program.all q: 'hats', has_products: true
#=> [<Program>,...]

programs_that_sell_hats.count
#=> 84

first_program = programs_that_sell_hats.first
#=> <Program>

first_program.name
#=> "Asos.com DE"

first_program.products
#=> 50129
```

**Search for a fitting product to an comment**

```ruby
adspaces = ZanoxPublisher::AdSpace.all
#=> [<AdSpace>,...]

adspace  = adspaces.select { |adspace| adspace.url == 'http://www.my-blog.com/' }.first
#=> <AdSpace>

my_programs = ZanoxPublisher::ProgramApplication.all(status: 'confirmed').map(&:program)
#=> [<Program>,...]

comment = params['comment']
#=> 'I also want a baseball cap.'

products = ZanoxPublisher::Product.page 0, per_page: 1, query: comment, adspace: adspace, programs: my_programs
#=> [<Product>]

product = products.first
#=> <Product>

product.tracking_links.first.ppc
#=> "http://ad.zanox.com/ppv/?..."
```

### List of Objects (Implimented)

* `ZanoxPublisher::AdMedium`: GetAdmedia, GetAdmedium
* `ZanoxPublisher::AdSpace`: GetAdspaces, GetAdspace
* `ZanoxPublisher::Incentive`: SearchIncentives, GetIncentive
* `ZanoxPublisher::ExclusiveIncentive`: SearchExclusiveIncentives, GetExclusiveIncentive
* `ZanoxPublisher::Product`: SearchProducts, GetProduct
* `ZanoxPublisher::Profile`: getProfiles
* `ZanoxPublisher::Program`: SearchPrograms, GetProgram
* `ZanoxPublisher::ProgramApplication`: GetProgramApplications

## Documentation

[http://www.rubydoc.info/github/oliverprater/zanox_publisher/master][documentation]

[documentation]: http://www.rubydoc.info/github/oliverprater/zanox_publisher/master

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0][semver]. Violations
of this scheme should be reported as bugs. Specifically, if a minor or patch
version is released that breaks backward compatibility, that version should be
immediately yanked and/or a new version should be immediately released that
restores compatibility. Breaking changes to the public API will only be
introduced with new major versions. As a result of this policy, you can (and
should) specify a dependency on this gem using the [Pessimistic Version
Constraint][pvc] with two digits of precision. For example:

    'zanox_publisher', '~> 0.1'

[semver]: http://semver.org/
[pvc]: http://docs.rubygems.org/read/chapter/16#page74

## Contributing

1. Fork it ( https://github.com/oliverprater/zanox_publisher/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright (c) 2015 Oliver Prater.
See [LICENSE][license] for details.

[license]: LICENSE.md
