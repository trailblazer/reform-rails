module Rails
  module Generators
    class FormGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      check_class_collision suffix: 'Form'

      argument :properties,
               type: :array,
               default: [],
               banner: 'property property2'

      def create_form_file
        template 'form.rb.erb', File.join('app/forms', class_path, "#{file_name}_form.rb")
      end

      hook_for :test_framework
    end
  end
end
