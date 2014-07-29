require 'test_helper'
require_relative 'project_with_tasks_containing_deliverable_form_fixture'

class MainCollectionFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  fixtures :projects, :tasks, :deliverables

  def setup
    @project = Project.new
    @form = ProjectWithTasksContainingDeliverableFormFixture.new(@project)
    @model = @form
  end

  test "Form declares association" do
    assert_respond_to ActiveForm::Form, :association
  end

  test "Form contains a list of sub-forms" do
    assert_respond_to ActiveForm::Form, :forms
    assert_equal 1, ActiveForm::Form.forms.size
  end

  test "forms list contains form definitions" do
    deliverable_definition = ActiveForm::Form.forms.first

    assert_equal :deliverable, deliverable_definition.assoc_name
  end

  test "main form provides getter method for tasks collection form" do
    tasks_form = @form.forms.first

    assert_instance_of ActiveForm::FormCollection, tasks_form
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    tasks_form = @form.forms.first

    assert tasks_form.represents?("tasks")
    assert_not tasks_form.represents?("task")
  end

  test "main form provides getter method for collection objects" do
    assert_respond_to @form, :tasks

    tasks = @form.tasks

    tasks.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Task, form.model
    end
  end

  test "tasks sub-form contains association name and parent model" do
    tasks_form = @form.forms.first

    assert_equal :tasks, tasks_form.association_name
    assert_equal 2, tasks_form.records
    assert_equal @project, tasks_form.parent
  end

  test "each tasks_form declares a deliverable form" do
    task_form = @form.tasks.first

    assert_equal 1, task_form.forms.size

    @form.tasks.each do |task_form|
      deliverable_form = task_form.deliverable

      assert_instance_of ActiveForm::Form, deliverable_form
      assert_equal :deliverable, deliverable_form.association_name
      assert_equal task_form.model, deliverable_form.parent
      assert_instance_of Deliverable, deliverable_form.model
    end
  end

  test "main form initializes the number of records specified" do
    tasks_form = @form.forms.first

    assert_respond_to tasks_form, :models
    assert_equal 2, tasks_form.models.size

    tasks_form.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Task, form.model
      assert_respond_to form, :name
      assert_respond_to form, :name=

      deliverable_form = form.deliverable
      assert_instance_of Deliverable, deliverable_form.model
      assert_respond_to deliverable_form, :description
      assert_respond_to deliverable_form, :description=
    end

    assert_equal 2, @form.model.tasks.size
  end

  test "main form fetches parent and association objects" do
    project = projects(:yard)

    form = ProjectWithTasksContainingDeliverableFormFixture.new(project)

    assert_equal project.name, form.name
    assert_equal project.tasks[0], form.tasks[0].model
    assert_equal project.tasks[0].deliverable, form.tasks[0].deliverable.model
    assert_equal project.tasks[1], form.tasks[1].model
    assert_equal project.tasks[1].deliverable, form.tasks[1].deliverable.model
  end

  test "main form syncs its model and the models in nested sub-forms" do
    params = {
      name: "Life",
      
      tasks_attributes: {
        "0" => {
          name: "Eat",

          deliverable_attributes: {
            description: "You will be stuffed."
          }
        },
        "1" => {
          name: "Pray",

          deliverable_attributes: {
            description: "You will have a clean soul."
          }
        }
      }
    }

    @form.submit(params)

    assert_equal "Life", @form.name
    assert_equal "Eat", @form.tasks[0].name
    assert_equal "You will be stuffed.", @form.tasks[0].deliverable.description
    assert_equal "Pray", @form.tasks[1].name
    assert_equal "You will have a clean soul.", @form.tasks[1].deliverable.description
  end

  test "main form validates itself" do
    params = {
      name: "Life",
      
      tasks_attributes: {
        "0" => {
          name: "Eat",

          deliverable_attributes: {
            description: "You will be stuffed."
          }
        },
        "1" => {
          name: "Pray",

          deliverable_attributes: {
            description: "You will have a clean soul."
          }
        }
      }
    }

    @form.submit(params)

    assert @form.valid?

    params = {
      name: nil,
      
      tasks_attributes: {
        "0" => {
          name: nil,

          deliverable_attributes: {
            description: nil
          }
        },
        "1" => {
          name: nil,

          deliverable_attributes: {
            description: nil
          }
        }
      }
    }

    @form.submit(params)

    assert_not @form.valid?
    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "can't be blank"
    assert_equal 5, @form.errors.messages[:name].size
  end

  test "main form saves its model and the models in nested sub-forms" do
    params = {
      name: "Life",
      
      tasks_attributes: {
        "0" => {
          name: "Eat",

          deliverable_attributes: {
            description: "You will be stuffed."
          }
        },
        "1" => {
          name: "Pray",

          deliverable_attributes: {
            description: "You will have a clean soul."
          }
        }
      }
    }

    @form.submit(params)

    assert_difference('Project.count') do
      @form.save
    end

    assert_equal "Life", @form.name
    assert_equal "Eat", @form.tasks[0].name
    assert_equal "You will be stuffed.", @form.tasks[0].deliverable.description
    assert_equal "Pray", @form.tasks[1].name
    assert_equal "You will have a clean soul.", @form.tasks[1].deliverable.description
    assert_equal 2, @form.tasks.size

    assert @form.persisted?

    @form.tasks.each do |task|
      assert task.persisted?
      assert task.deliverable.persisted?
    end
  end

  test "main form updates its model and the models in nested sub-forms" do
    project = projects(:yard)
    form = ProjectWithTasksContainingDeliverableFormFixture.new(project)
    params = {
      name: "Life",
      
      tasks_attributes: {
        "0" => {
          name: "Eat",
          id: tasks(:rake).id,

          deliverable_attributes: {
            description: "You will be stuffed.",
            id: deliverables(:leaves).id
          }
        },
        "1" => {
          name: "Pray",
          id: tasks(:paint).id,

          deliverable_attributes: {
            description: "You will have a clean soul.",
            id: deliverables(:fence).id
          }
        }
      }
    }

    form.submit(params)

    assert_difference('Project.count', 0) do
      form.save
    end

    assert_equal "Life", form.name
    assert_equal "Eat", form.tasks[0].name
    assert_equal "You will be stuffed.", form.tasks[0].deliverable.description
    assert_equal "Pray", form.tasks[1].name
    assert_equal "You will have a clean soul.", form.tasks[1].deliverable.description
  end

  test "main form responds to writer method" do
    assert_respond_to @form, :tasks_attributes=
  end

  test "tasks form responds to writer method" do
    @form.tasks.each do |task_form|
      assert_respond_to task_form, :deliverable_attributes=
    end
  end
end
