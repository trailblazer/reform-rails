# 0.3.1

* Fix: ActiveModel acceptance validator wasn't properly monkey patched
  Now this will work in environments where active model and active record is
  not loaded by default. In addition, it will work with all the Rails versions
  we support

# 0.3.0

* Add `conditions` option to Reform Uniqueness validation.
* ActiveModel acceptance validation works

# 0.2.6

* Allow to override `#persisted?` and friends with modules.

# 0.2.5

* Fix: Delegating from form object causes ArgumentError with 0.2.4 (https://github.com/trailblazer/reform-rails/issues/99)

# 0.2.4

* Fix keyword argument warning in `method_missing` (https://github.com/trailblazer/reform-rails/pull/97)
* Internal: Replace Uber::Delegates with Forwardable in Form::ActiveModel

# 0.2.3

* Fix deprecation warning related to `respond_to?`

# 0.2.2

* Support ActiveRecord 6.1

# 0.2.1

* Error's full_message  with translation fixed thanks to [@marcelolx](https://github.com/trailblazer/reform-rails/pull/85)

# 0.2.0

* Needs Reform >= 2.3.0.
* make the inclusion of ActiveModel form builder modules optional when using dry-validation. This can be controlled via `config.reform.enable_active_model_builder_methods = true`.
* delegate `validates_each` method and allow it to be called outside a validation block.
* add `case_sensitive` option to Reform Uniqueness validation. Defaults to true.
* fix bug in uniqueness validation where form has different attribute name to column
* improve handling of persisted records in uniqueness validator
* remove params.merge! as it's deprecated in rails 5
* update to support reform 2.3, the new API means that `errors.add` is delegated to ActiveModel::Errors to support rails 5
* Fix nested form validation (#53)
* Errors supports symbol and string lookup (PR #77)
* Implement respond_to that delegates to AMV errors (PR #78)
* Drop support for activemodel before 5.0

# 0.1.8
* Drop support to mongoid < 4.

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
