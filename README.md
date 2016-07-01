# Reform::Rails

[![Gitter Chat](https://badges.gitter.im/trailblazer/chat.svg)](https://gitter.im/trailblazer/chat)
[![TRB Newsletter](https://img.shields.io/badge/TRB-newsletter-lightgrey.svg)](http://trailblazer.to/newsletter/)
[![Build
Status](https://travis-ci.org/apotonick/reform-rails.svg)](https://travis-ci.org/apotonick/reform-rails)
[![Gem Version](https://badge.fury.io/rb/reform-rails.svg)](http://badge.fury.io/rb/reform-rails)

_Rails-support for Reform_.

Loads Rails-specific Reform files and includes modules like `Reform::Form::ActiveModel` automatically.

Simply don't include this gem if you don't want to use the conventional Reform/Rails stack. For example in a Hanami environment or when using dry-validations, refrain from using this gem.

## Documentation

The [full documentation](http://trailblazer.to/gems/reform/#reform-rails) can be found on the Trailblazer page.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reform-rails'
```

Reform-rails needs Reform >= 2.2.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

