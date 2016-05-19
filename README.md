# Reform::Rails

Loads Rails-specific Reform files and includes modules like `Reform::Form::ActiveModel` automatically.

Simply don't include this gem if you don't want to use the standard Reform/Rails stack, for example because you're in a Lotus environment or you intend to use Veto validations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reform-rails'
```

## Generators

This gem also have support of rails generators:

```
bin/rails g form Test property1 property2
```

It will generate TestForm in `app/forms` dir.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
