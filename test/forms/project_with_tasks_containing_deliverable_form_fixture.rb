class ProjectWithTasksContainingDeliverableFormFixture < ActiveForm::Base
  attribute :name, required: true

  association :tasks, records: 2 do
    attribute :name, required: true

    association :deliverable do
      attribute :description
    end
  end
end