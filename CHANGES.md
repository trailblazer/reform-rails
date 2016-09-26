# master

* make the inclusion of ActiveModel form builder modules optional when using dry-validation. This can be controlled via `config.reform.enable_active_model_builder_methods = true`.

* delegate `validates_each` method and allow it to be called outside a validation block.


# 0.1.7 (0.1.6 Yanked)

* Fix a bug where requiring `form/active_model/validations` in a non-Rails environment wouldn't load all necessary files.

# 0.1.5

* Allow using Reform-Rails without Rails (it used to crash when not loading `rails.rb`).

# 0.1.4

* Allow setting `config.reform` in initializers, too.

# 0.1.3

* Introduce a railtie to load either `ActiveModel::Validations` *or* `Dry::Validations`. This can be controlled via `config.reform.validations = :dry`.

# 0.1.2

* Allow Reform-2.2.0.rc1 in gemspec.

# 0.1.1

* First working release.
