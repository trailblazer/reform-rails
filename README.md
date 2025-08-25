# Reform::Rails

[![Gitter Chat](https://badges.gitter.im/trailblazer/chat.svg)](https://gitter.im/trailblazer/chat)
[![TRB Newsletter](https://img.shields.io/badge/TRB-newsletter-lightgrey.svg)](http://trailblazer.to/newsletter/)
[![Build
Status](https://travis-ci.org/trailblazer/reform-rails.svg)](https://travis-ci.org/trailblazer/reform-rails)
[![Gem Version](https://badge.fury.io/rb/reform-rails.svg)](http://badge.fury.io/rb/reform-rails)

_Rails-support for Reform_.

Loads Rails-specific Reform files and includes modules like `Reform::Form::ActiveModel` automatically.

Simply don't include this gem if you don't want to use the conventional Reform/Rails stack. For example in a Hanami environment or when using dry-validations, refrain from using this gem.

## Documentation

The [full documentation](https://trailblazer.to/2.0/gems/reform/rails.html) can be found on the Trailblazer page.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reform-rails'
```

Reform-rails needs Reform >= 2.3.

## Contributing

Please ensure that you test your changes against all supported ruby and rails versions

You can run tests for a specific version of rails by running the following:

```shell
BUNDLE_GEMFILE=Gemfile-rails7.0 bundle install
BUNDLE_GEMFILE=Gemfile-rails7.0 bundle exec rake test
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
