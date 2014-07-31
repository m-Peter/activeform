require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects, :tasks
  
  setup do
    @project = projects(:yard)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create project" do
    assert_difference('Project.count') do
      post :create, project: {
        name: "Life",
        
        tasks_attributes: {
          "0" => { name: "Eat" },
          "1" => { name: "Pray" },
          "2" => { name: "Love" },
        }
      }
    end

    project_form = assigns(:project_form)

    assert project_form.valid?
    assert_redirected_to project_path(project_form)
    
    assert_equal "Life", project_form.name
    
    assert_equal "Eat", project_form.tasks[0].name
    assert_equal "Pray", project_form.tasks[1].name
    assert_equal "Love", project_form.tasks[2].name

    project_form.tasks.each do |task|
      task.persisted?
    end
    
    assert_equal "Project: Life was successfully created.", flash[:notice]
  end

  test "should create dynamically added task to a project" do
    assert_difference('Project.count') do
      post :create, project: {
        name: "Life",
        
        tasks_attributes: {
          "0" => { name: "Eat" },
          "1" => { name: "Pray" },
          "2" => { name: "Love" },
          "1234" => { name: "Repeat" }
        }
      }
    end

    project_form = assigns(:project_form)

    assert project_form.valid?
    assert_redirected_to project_path(project_form)
    
    assert_equal "Life", project_form.name

    assert_equal 4, project_form.tasks.size
    
    assert_equal "Eat", project_form.tasks[0].name
    assert_equal "Pray", project_form.tasks[1].name
    assert_equal "Love", project_form.tasks[2].name
    assert_equal "Repeat", project_form.tasks[3].name

    project_form.tasks.each do |task|
      task.persisted?
    end
    
    assert_equal "Project: Life was successfully created.", flash[:notice]
  end

  test "should not create project with invalid params" do
    project = projects(:yard)

    assert_difference('Project.count', 0) do
      post :create, project: {
        name: project.name,
        
        tasks_attributes: {
          "0" => { name: nil },
          "1" => { name: nil },
          "2" => { name: nil },
        }
      }
    end

    project_form = assigns(:project_form)

    assert_not project_form.valid?

    assert_includes project_form.errors.messages[:name], "has already been taken"
    project_form.tasks.each do |task_form|
      assert_includes task_form.errors.messages[:name], "can't be blank"
    end
  end

  test "should show project" do
    get :show, id: @project
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @project
    assert_response :success
  end

  test "should update project" do
    assert_difference('Project.count', 0) do
      patch :update, id: @project, project: {
        name: "Car service",
        
        tasks_attributes: {
          "0" => { name: "Wash tires", id: @project.tasks[0].id },
          "1" => { name: "Clean inside", id: @project.tasks[1].id },
          "2" => { name: "Check breaks", id: @project.tasks[2].id },
        }
      }
    end

    project_form = assigns(:project_form)

    assert_redirected_to project_path(project_form)

    assert_equal "Car service", project_form.name
    
    assert_equal "Wash tires", project_form.tasks[0].name
    assert_equal "Clean inside", project_form.tasks[1].name
    assert_equal "Check breaks", project_form.tasks[2].name

    assert_equal "Project: Car service was successfully updated.", flash[:notice]
  end

  test "should destroy dynamically removed task from project" do
    assert_difference('Project.count', 0) do
      patch :update, id: @project, project: {
        name: "Car service",
        
        tasks_attributes: {
          "0" => { name: "Wash tires", id: @project.tasks[0].id },
          "1" => { name: "Clean inside", id: @project.tasks[1].id },
          "2" => { name: "Check breaks", id: @project.tasks[2].id, _destroy: "1" },
        }
      }
    end

    project_form = assigns(:project_form)

    assert_redirected_to project_path(project_form)

    assert_equal "Car service", project_form.name
    
    assert_equal "Wash tires", project_form.tasks[0].name
    assert_equal "Clean inside", project_form.tasks[1].name
    
    assert_equal 2, project_form.tasks.size

    assert_equal "Project: Car service was successfully updated.", flash[:notice]
  end

  test "should destroy project" do
    assert_difference('Project.count', -1) do
      delete :destroy, id: @project
    end

    assert_redirected_to projects_path
  end
end
