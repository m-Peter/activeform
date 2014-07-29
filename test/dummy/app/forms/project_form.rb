class ProjectForm < ActiveForm::Base
  attribute :name, required: true

  association :tasks, records: 3 do
    attribute :name, required: true
  end
end