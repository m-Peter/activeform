require 'test_helper'
require_relative 'project_with_tasks_form_fixture'

class NestedCollectionAssociationFormTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests
  fixtures :projects, :tasks

  def setup
    @project = Project.new
    @form = ProjectWithTasksFormFixture.new(@project)
    @tasks_form = @form.forms.first
    @model = @form
  end

  test "declares collection association" do
    assert_respond_to ProjectWithTasksFormFixture, :association
  end

  test "forms list contains tasks sub-form definition" do
    assert_equal 1, ProjectWithTasksFormFixture.forms.size

    tasks_definition = ProjectWithTasksFormFixture.forms[0]

    assert_equal :tasks, tasks_definition.assoc_name
  end

  test "main form provides getter method for tasks sub-form" do
    assert_instance_of ActiveForm::FormCollection, @tasks_form
  end

  test "tasks sub-form contains association name and parent" do
    assert_equal :tasks, @tasks_form.association_name
    assert_equal 3, @tasks_form.records
    assert_equal @project, @tasks_form.parent
  end

  test "#represents? returns true if the argument matches the Form's association name, false otherwise" do
    assert @tasks_form.represents?("tasks")
    assert_not @tasks_form.represents?("task")
  end

  test "main form provides getter method for task objects" do
    assert_respond_to @form, :tasks

    tasks = @form.tasks

    tasks.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Task, form.model
    end
  end

  test "main form initializes the number of records specified" do
    assert_respond_to @tasks_form, :models
    assert_equal 3, @tasks_form.models.size
    
    @tasks_form.each do |form|
      assert_instance_of ActiveForm::Form, form
      assert_instance_of Task, form.model
      assert form.model.new_record?

      assert_respond_to form, :name
      assert_respond_to form, :name=
    end

    assert_equal 3, @form.model.tasks.size
  end

  test "main form fetches models for existing parent" do
    project = projects(:yard)

    form = ProjectWithTasksFormFixture.new(project)

    assert_equal project.name, form.name
    assert_equal 3, form.tasks.size
    assert_equal project.tasks[0], form.tasks[0].model
    assert_equal project.tasks[1], form.tasks[1].model
    assert_equal project.tasks[2], form.tasks[2].model
  end

  test "main form syncs its model and the models in nested sub-forms" do
    params = {
      name: "Life",

      tasks_attributes: {
        "0" => { name: "Eat" },
        "1" => { name: "Pray" },
        "2" => { name: "Love" }
      }
    }

    @form.submit(params)

    assert_equal "Life", @form.name
    assert_equal "Eat", @form.tasks[0].name
    assert_equal "Pray", @form.tasks[1].name
    assert_equal "Love", @form.tasks[2].name
    assert_equal 3, @form.tasks.size
  end

  test "main form validates itself" do
    params = {
      name: "Life",

      tasks_attributes: {
        "0" => { name: "Eat" },
        "1" => { name: "Pray" },
        "2" => { name: "Love" }
      }
    }

    @form.submit(params)

    assert @form.valid?

    params = {
      name: "Life",

      tasks_attributes: {
        "0" => { name: nil },
        "1" => { name: nil },
        "2" => { name: nil }
      }
    }

    @form.submit(params)

    assert_not @form.valid?
    assert_includes @form.errors.messages[:name], "can't be blank"
    assert_equal 3, @form.errors.messages[:name].size
  end

  test "tasks sub-form raises error if records exceed the allowed number" do
    params = {
      name: "Life",

      tasks_attributes: {
        "0" => { name: "Eat" },
        "1" => { name: "Pray" },
        "2" => { name: "Love" },
        "3" => { name: "Dummy" }
      }
    }

    #exception = assert_raises(TooManyRecords) { @form.submit(params) }
    #assert_equal "Maximum 3 records are allowed. Got 4 records instead.", exception.message
  end

  test "main form saves its model and the models in nested sub-forms" do
    params = {
      name: "Life",

      tasks_attributes: {
        "0" => { name: "Eat" },
        "1" => { name: "Pray" },
        "2" => { name: "Love" }
      }
    }

    @form.submit(params)

    assert_difference('Project.count') do
      @form.save
    end

    assert_equal "Life", @form.name
    assert_equal "Eat", @form.tasks[0].name
    assert_equal "Pray", @form.tasks[1].name
    assert_equal "Love", @form.tasks[2].name
    assert_equal 3, @form.tasks.size

    assert @form.persisted?
    @form.tasks.each do |task|
      assert task.persisted?
    end
  end

  test "main form saves its model and dynamically added models in nested sub-forms" do
    params = {
      name: "Life",

      tasks_attributes: {
        "0" => { name: "Eat" },
        "1" => { name: "Pray" },
        "2" => { name: "Love" },
        "1404292088779" => { name: "Repeat" }
      }
    }

    @form.submit(params)

    assert_difference('Project.count') do
      @form.save
    end

    assert_equal "Life", @form.name
    assert_equal "Eat", @form.tasks[0].name
    assert_equal "Pray", @form.tasks[1].name
    assert_equal "Love", @form.tasks[2].name
    assert_equal "Repeat", @form.tasks[3].name
    assert_equal 4, @form.tasks.size

    assert @form.persisted?
    @form.tasks.each do |task|
      assert task.persisted?
    end
  end

  test "main form updates its model and the models in nested sub-forms" do
    project = projects(:yard)
    form = ProjectWithTasksFormFixture.new(project)
    params = {
      name: "Life",
      
      tasks_attributes: {
        "0" => { name: "Eat", id: tasks(:rake).id },
        "1" => { name: "Pray", id: tasks(:paint).id },
        "2" => { name: "Love", id: tasks(:clean).id }
      }
    }

    form.submit(params)

    assert_difference('Project.count', 0) do
      form.save
    end

    assert_equal "Life", form.name
    assert_equal "Eat", form.tasks[0].name
    assert_equal "Pray", form.tasks[1].name
    assert_equal "Love", form.tasks[2].name
    assert_equal 3, form.tasks.size
    
    assert form.persisted?
  end

  test "main form updates its model and saves dynamically added models in nested sub-forms" do
    project = projects(:yard)
    form = ProjectWithTasksFormFixture.new(project)
    params = {
      name: "Life",
      
      tasks_attributes: {
        "0" => { name: "Eat", id: tasks(:rake).id },
        "1" => { name: "Pray", id: tasks(:paint).id },
        "2" => { name: "Love", id: tasks(:clean).id },
        "1404292088779" => { name: "Repeat" }
      }
    }

    form.submit(params)

    assert_difference('Project.count', 0) do
      form.save
    end

    assert_equal "Life", form.name
    assert_equal "Eat", form.tasks[0].name
    assert_equal "Pray", form.tasks[1].name
    assert_equal "Love", form.tasks[2].name
    assert_equal "Repeat", form.tasks[3].name
    assert_equal 4, form.tasks.size
    
    assert form.persisted?
    form.tasks.each do |task|
      assert task.persisted?
    end
  end

  test "main form deletes models in nested sub-forms" do
    project = projects(:yard)
    form = ProjectWithTasksFormFixture.new(project)
    params = {
      name: "Life",
      
      tasks_attributes: {
        "0" => { name: "Eat", id: tasks(:rake).id },
        "1" => { name: "Pray", id: tasks(:paint).id },
        "2" => { name: "Love", id: tasks(:clean).id, "_destroy" => "1" },
      }
    }

    form.submit(params)

    assert project.tasks[2].marked_for_destruction?

    assert_difference('Project.count', 0) do
      form.save
    end

    assert_equal "Life", form.name
    assert_equal "Eat", form.tasks[0].name
    assert_equal "Pray", form.tasks[1].name
    assert_equal 2, form.tasks.size

    assert form.persisted?
    form.tasks.each do |task|
      assert task.persisted?
    end
  end

  test "main form deletes and adds models in nested sub-forms" do
    project = projects(:yard)
    form = ProjectWithTasksFormFixture.new(project)
    params = {
      name: "Life",
      
      tasks_attributes: {
        "0" => { name: "Eat", id: tasks(:rake).id },
        "1" => { name: "Pray", id: tasks(:paint).id },
        "2" => { name: "Love", id: tasks(:clean).id, "_destroy" => "1" },
        "1404292088779" => { name: "Repeat" }
      }
    }

    form.submit(params)

    assert project.tasks[2].marked_for_destruction?

    assert_difference('Project.count', 0) do
      form.save
    end

    assert_equal "Life", form.name
    assert_equal "Eat", form.tasks[0].name
    assert_equal "Pray", form.tasks[1].name
    assert_equal "Repeat", form.tasks[2].name
    assert_equal 3, form.tasks.size

    assert form.persisted?
    form.tasks.each do |task|
      assert task.persisted?
    end
  end

  test "main form responds to writer method" do
    assert_respond_to @form, :tasks_attributes=
  end
end