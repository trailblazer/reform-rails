# master

* make the inclusion of ActiveModel form builder modules optional when using dry-validation. This can be controlled via `config.reform.enable_active_model_builder_methods = true`.

* delegate `validates_each` method and allow it to be called outside a validation block.

* add `case_sensitive` option to Reform Uniqueness validation. Defaults to true.

* fix bug in uniqueness validation where form has different attribute name to column

* improve handling of persisted records in uniqueness validator

* remove params.merge! as it's deprecated in rails 5

* update to support reform 2.3, the new API means that `errors.add` is delegated to ActiveModel::Errors so we have support for rails 5 :descriptions without having to do anything !Yey!
* Fix nested form validation (#53)

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
