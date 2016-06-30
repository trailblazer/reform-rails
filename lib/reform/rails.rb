require "reform/rails/version"
require "reform/rails/railtie"

module Reform
  def self.rails3_0?
    ::ActiveModel::VERSION::MAJOR == 3 and ::ActiveModel::VERSION::MINOR == 0
  end
end
