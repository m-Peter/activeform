module ActiveForm
  autoload :Base, 'active_form/base'
  autoload :Form, 'active_form/form'
  autoload :FormCollection, 'active_form/form_collection'
  autoload :FormDefinition, 'active_form/form_definition'
  autoload :TooManyRecords, 'active_form/too_many_records'
  autoload :ViewHelpers, 'active_form/view_helpers'

  class Engine < ::Rails::Engine
    initializer "active_form.initialize" do |app|
      ActiveSupport.on_load :action_view do
        include ActiveForm::ViewHelpers
      end
    end
  end
end
