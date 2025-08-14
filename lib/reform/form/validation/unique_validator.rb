# === Unique Validation
# Reform's own implementation for uniqueness which does not write to model
#
# == Usage
# Pass a true boolean value to validate a field against all values available in
# the database:
# validates :title, unique: true
#
# == Options
#
# = Case Sensitivity
# Case sensitivity is true by default, but can be set to false:
#
# validates :title, unique: { case_sensitive: false }
#
# = Scope
# A scope can be used to filter the records that need to be compare with the
# current value to validate. A scope array can have one to many fields define.
#
# A scope can be define the following ways:
# validates :title, unique: { scope: :album_id }
# validates :title, unique: { scope: [:album_id] }
# validates :title, unique: { scope: [:album_id, ...] }
#
# All fields included in a scope must be declared as a property like this:
# property :album_id
# validates :title, unique: { scope: :album_id }
#
# Just remove write access to the property if the field must not be change:
# property :album_id, writeable: false
# validates :title, unique: { scope: :album_id }
#
# This use case is useful if album_id is set to a Song this way:
# song = album.songs.new
# album_id is automatically set and can't be change by the operation
#
# = Conditions
# A condition can be passed to filter the records with partial indexes
#
# Conditions can be define the following ways:
# validates :title, unique: { conditions: -> { where(archived_at: nil) } }
# - This will check that the title is unique for non archived records
# validates :title, unique: {
#   conditions: ->(record) {
#     published_at = record.published_at
#     where(published_at: published_at.beginning_of_year..published_at.end_of_year)
#   }
# }
#

class Reform::Form::UniqueValidator < ActiveModel::EachValidator
  def validate_each(form, attribute, value)
    model = form.model_for_property(attribute)
    original_attribute = form.options_for(attribute)[:private_name]

    # search for models with attribute equals to form field value
    query = if options[:case_sensitive] == false && value
              model.class.where("lower(#{original_attribute}) = ?", value.downcase)
            else
              model.class.where(original_attribute => value)
            end

    # if model persisted, query should bypass model
    if model.persisted?
      query = query.where("#{model.class.primary_key} != ?", model.id)
    end

    # apply scope if options has been declared
    Array(options[:scope]).each do |field|
      # add condition to only check unique value with the same scope
      query = query.where(field => form.send(field))
    end

    if options[:conditions]
      conditions = options[:conditions]

      query = if conditions.arity.zero?
                query.instance_exec(&conditions)
              else
                query.instance_exec(form, &conditions)
              end
    end

    form.errors.add(attribute, :taken) if query.count > 0
  end
end

# FIXME: ActiveModel loads validators via const_get(#{name}Validator). This magic forces us to
# make the new :unique validator available here.
Reform::Form::ActiveModel::Validations::Validator.class_eval do
  UniqueValidator = Reform::Form::UniqueValidator
end
